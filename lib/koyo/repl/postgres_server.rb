# frozen_string_literal: true

module Koyo
  module Repl
    # Monitors a postgres replication slot
    class PostgresServer
      include Koyo::Repl::Log

      class << self
        attr_accessor :tables
      end

      attr_accessor :tables, # classes that implement koyo_repl_handler(row)
                    :test_mode, # when true - only peeks at slot
                    :errs # collects error messages - these are sent to log

      attr_writer :tick_tock # just outputs something in logs every minute

      # method name to look for in classes that support this
      TABLE_METHOD_NAME = :koyo_repl_handler

      def self.run!
        new.run!
      end

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

      def run!
        # This allows us to catch ctrl-c and exit
        trap('SIGINT') { throw :done }

        catch(:done) do
          check
          sleep Koyo::Repl.config.sql_delay
          tick_tock
          run!
        # Possibly fatal errors
        rescue ActiveRecord::StatementInvalid => e
          if e.cause.exception.is_a?(PG::ConnectionBad)
            Koyo::Repl::EventHandlerService.koyo_error(e)
            msg = "SHUTTING DOWN. Fatal Error in ReplPostgresServer: #{e.message}"
            log_repl_fatal(msg, err: e)
          else
            log_recoverable_error(e)
            run!
          end
        rescue StandardError => e
          log_recoverable_error(e)
          run!
        end
      end

      def log_recoverable_error(err)
        Koyo::Repl::EventHandlerService.koyo_error(err)
        msg = "Error in ReplPostgresServer: #{err.message}"
        log_repl_error(msg, err: err)
        sleep Koyo::Repl.config.sql_delay
      end

      def tick_tock
        @tick_tock += 1
        return unless @tick_tock > 59

        log_repl_info("tick tock: #{Time.now}")
        @tick_tock = 0
      end

      # Does a single check of the replication slot
      #
      # @param test_mode [Boolean] - default: false. If true uses peek, which will
      # leave data in the replication slot (for testing/debugging)
      def check
        read_sql_results.each do |sql_res|
          rows = Koyo::Repl::Data.new(sql_res).rows # returns ReplDataRow
          rows.each do |row|
            check_row(row)
          end
        end
      end

      def read_sql_results
        if test_mode
          Koyo::Repl::Database.peek_slot
        else
          Koyo::Repl::Database.read_slot!
        end
      end

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

      # checks basics to see if we can run
      # logs errors (should be visible in whatever is running the server
      # returns t/f
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

        log_repl_info("Init: Finding models that support #{TABLE_METHOD_NAME}")
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
