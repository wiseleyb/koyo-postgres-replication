# frozen_string_literal: true

module Koyo::Repl
  # Monitors a postgres replication slot
  class PostgresServer
    include Koyo::Repl::Log

    @@tables = {} # somewhat expensive to create - so cache

    attr_accessor :tables,  # classes that implement koyo_repl_handler(row)
                  :test_mode, # when true - only peeks at slot
                  :tick_tock, # just outputs something in logs every minute
                  :errs # collects error messages - these are sent to log

    # method name to look for in classes that support this
    TABLE_METHOD_NAME = :koyo_repl_handler

    def self.run!
      new.run!
    end

    def initialize
      @test_mode = Koyo::Repl.config.test_mode
      if Koyo::Repl.config.auto_create_replication_slot
        Koyo::Repl::Utils.create_replication_slot!
      end
      @tables = Koyo::Repl::PostgresServer.tables_that_handle_koyo_replication
      @errs = []
      @tick_tock = 0
      raise "Can't run server: #{@errs.join('; ')}" unless can_run?
    end

    def run!
      catch(:done) do
        check
        sleep Koyo::Repl.config.sql_delay
        tick_tock
        run!
      rescue StandardError => e
        msg = "Error in ReplPostgresServer: #{e.message}"
        log_repl_error(msg, err: e)
        sleep Koyo::Repl.config.sql_delay
        run!
      end
    end

    def tick_tock
      @tick_tock += 1
      if @tick_tock > 59
        log_repl_info("tick tock: #{Time.now}")
        @tick_tock = 0
      end
    end

    # Does a single check of the replication slot
    #
    # @param test_mode [Boolean] - default: false. If true uses peek, which will
    # leave data in the replication slot (for testing/debugging)
    def check
      sql_results = test_mode ? Koyo::Repl::Utils.peek_slot : Koyo::Repl::Utils.read_slot!
      sql_results.each do |sql_res|
        rows = Koyo::Repl::Data.new(sql_res).rows # returns ReplDataRow
        rows.each do |row|
          log_repl_debug(row.to_yaml)
          # handle catch all if it exists
          if Koyo::Repl.config.handler_klass
            Koyo::Repl.config.handler_klass.constantize
                      .koyo_handle_all_replication(row)
          end
          next unless tables.include?(row.table)

          # handle model callbacks
          klass = tables[row.table].constantize
          mname = klass.send("#{TABLE_METHOD_NAME}_method")
          klass.send(mname, row)
        rescue StandardError => e
          log_repl_error('Unexpected Error in ReplServer.check', err: e)
        end
      end
    end

    # checks basics to see if we can run
    # logs errors (should be visible in whatever is running the server
    # returns t/f
    def can_run?
      @errs = []

      # check if replication slot is setup
      unless Koyo::Repl::Utils.replication_slot_exists?
        errs << "Error: Replication Slot doesn't exist. "\
                 'See koyo-postgres-replication gem for how to set this up.'
      end

      # check if any tables are setup to handle replication events
      unless tables.present?
        errs << "Error: No models implement self.#{TABLE_METHOD_NAME}. "\
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
      return @@tables if @@tables.present?
      method_name = TABLE_METHOD_NAME
      log_repl_info("Init: Finding models that support #{method_name}")
      tables = {}
      ActiveRecord::Base.connection.tables.map do |model|
        klass_name = model.capitalize.singularize.camelize
        klass = klass_name.constantize
        next unless klass.methods.include?(method_name)

        tables[klass.table_name] = klass_name
      rescue NameError # filters out stuff like SchemaMigration
        log_repl_info("Init: ignoring model #{klass_name}")
      rescue StandardError => e
        log_repl_error('Unexpected Error in '\
            'ReplServer.tables_that_handle_koyo_replication',
            err: e)
      end
      tables.each do |t|
        log_repl_info("Init: registering handler #{t}")
      end
      @@tables = tables
      @@tables
    end
  end
end
