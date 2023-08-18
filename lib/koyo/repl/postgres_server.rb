# frozen_string_literal: true

module Koyo
  module Repl
    # Monitors a postgres replication slot and fires off events
    # for monitoring to models and a catch-all class
    class PostgresServer
      # includes log helpers
      include Koyo::Repl::Log

      class << self
        attr_accessor :tables # cache of class level :tables
      end

      attr_accessor :tables, # classes that implement koyo_repl_handler(row)
                    :test_mode, # when true - only peeks at slot
                    :errs # collects error messages - these are sent to log

      attr_writer :tick_tock # just outputs something in logs every minute

      # Method name to look for in models that support this
      # @see Model callbacks
      # https://github.com/wiseleyb/koyo-postgres-replication/wiki/Model-call-backs
      TABLE_METHOD_NAME = :koyo_repl_handler

      # Runs the server. You should only be running ONE of these
      # servers at a time.
      def self.run!
        new.run!
      end

      # Initialize server: checks for basics and fails if things
      # aren't setup
      def initialize
        @test_mode = Koyo::Repl.config.test_mode
        if Koyo::Repl.config.auto_create_replication_slot
          Koyo::Repl::Database.create_replication_slot!
        end
        @tables = Koyo::Repl::PostgresServer.tables_that_handle_koyo_replication
        @errs = []
        @tick_tock = 0
        raise "Can't run server: #{@errs.join('; ')}" unless can_run?
      end

      # Runs the server. You should only be running ONE of these
      # servers at a time.
      def run!
        loop do
          begin
            check
            tick_tock
          # Possibly fatal errors
          rescue ActiveRecord::StatementInvalid => e
            if e.cause.exception.is_a?(PG::ConnectionBad)
              Koyo::Repl::EventHandlerService.koyo_error(e)
              msg = "SHUTTING DOWN. Fatal Error in ReplPostgresServer: #{e.message}"
              log_repl_fatal(msg, err: e)
              break
            else
              log_recoverable_error(e)
            end
          # recoverable error
          rescue StandardError => e
            log_recoverable_error(e)
          end

          success = system("sleep #{Koyo::Repl.config.sql_delay}")
          break unless success
        end
      end

      # Handles erros that aren't fatal. Calls back to
      # Koyo::Repl::Log@log_repl_error which calls back
      # to KoyoReplHandlerServer@log_repl_error
      def log_recoverable_error(err)
        Koyo::Repl::EventHandlerService.koyo_error(err)
        msg = "Error in ReplPostgresServer: #{err.message}"
        log_repl_error(msg, err:)
      end

      # Basic heart beat ping to allow you to see the server is still
      # running. Pings every 60 seconds
      def tick_tock
        @tick_tock += 1
        return unless @tick_tock > 59

        log_repl_info("tick tock: #{Time.now}")
        @tick_tock = 0
      end

      # Does a single check of the replication slot
      # If test_mode=true uses peek, which will
      # leave data in the replication slot (for testing/debugging)
      def check
        read_sql_results.each do |sql_res|
          rows = Koyo::Repl::Data.new(sql_res).rows # returns ReplDataRow
          rows.each do |row|
            check_row(row)
          end
        end
      end

      # Reads data from the replication slot
      # Handles test_mode (so will only peek if true)
      def read_sql_results
        if test_mode
          Koyo::Repl::Database.peek_slot
        else
          Koyo::Repl::Database.read_slot!
        end
      end

      # Processes a row from the replication slot
      # @param row Koyo::Repl::DataRow
      # @see For details on row
      # https://github.com/wiseleyb/koyo-postgres-replication/wiki/Koyo::Repl::DataRow-data-spec
      def check_row(row)
        log_repl_debug(row.to_yaml)
        # catch all for all events (allows rails project to use this
        # instead of models
        Koyo::Repl::EventHandlerService.koyo_handle_all_replication(row)

        return unless tables.include?(row.table)

        # handle model callbacks
        klass = tables[row.table].constantize
        mname = klass.send("#{TABLE_METHOD_NAME}_method")
        klass.send(mname, row)
      rescue StandardError => e
        Koyo::Repl::EventHandlerService.koyo_error(e)
        log_repl_error('Unexpected Error in ReplServer.check', err: e)
      end

      # Checks basics to see if we can run
      # Logs errors (should be visible in whatever is running the server
      # @return true can run when true or false (can't run)
      def can_run?
        @errs = []

        # check if replication slot is setup
        unless Koyo::Repl::Database.replication_slot_exists?
          errs << "Error: Replication Slot doesn't exist. "\
                   'See koyo-postgres-replication gem for how to set this up.'
        end

        # if there were any errors - let user know we're shutting down
        errs << 'Shutting down' unless errs.empty?

        errs.each { |msg| log_repl_error(msg) }

        errs.empty?
      end

      # Finds all models that that implement 'self.koyo_repl_handler'
      # This is only run once - during server spin up
      def self.tables_that_handle_koyo_replication
        return tables if tables.present?

        log_repl_info('Init: Finding models that support '\
                      "#{TABLE_METHOD_NAME}")
        tables = {}
        ActiveRecord::Base.connection.tables.map do |model|
          klass_name = model.capitalize.singularize.camelize
          klass = klass_name.constantize
          next unless klass.methods.include?(TABLE_METHOD_NAME)

          tables[klass.table_name] = klass_name
        rescue NameError # filters out stuff like SchemaMigration
          log_repl_info("Init: ignoring model #{klass_name}")
        rescue StandardError => e
          Koyo::Repl::EventHandlerService.koyo_error(e)
          log_repl_error('Unexpected Error in '\
              'ReplServer.tables_that_handle_koyo_replication',
                         err: e)
        end
        tables.each do |t|
          log_repl_info("Init: registering handler #{t}")
        end
        tables
      end
    end
  end
end
