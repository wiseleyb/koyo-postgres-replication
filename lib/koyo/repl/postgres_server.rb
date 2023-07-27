# frozen_string_literal: true

module Koyo::Repl
  # Monitors a postgres replication slot
  class PostgresServer
    @@tables = {} # somewhat expensive to create - so cache

    attr_accessor :tables,  # classes that implement koyo_repl_handler(row)
                  :test_mode, # when true - only peeks at slot
                  :errs # collects error messages - these are sent to log

    # method name to look for in classes that support this
    TABLE_METHOD_NAME = :koyo_repl_handler

    def self.run!
      new.run!
    end

    def initialize
      @test_mode = Koyo::Repl::Config.test_mode
      if Koyo::Repl::Config.auto_create_replication_slot?
        Koyo::Repl::Utils.create_replication_slot!
      end
      @tables = Koyo::Repl::PostgresServer.tables_that_handle_koyo_replication
      @errs = []
      raise "Can't run server: #{@errs.join('; ')}" unless can_run?
    end

    def run!
      catch(:done) do
        check
        sleep Koyo::Repl::Config.sql_delay
        run!
      rescue StandardError => e
        msg = "Error in ReplPostgresServer: #{e.message}"
        log(msg, err: e)
        sleep Koyo::Repl::Config.sql_delay
        run!
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
          next unless tables.include?(row.table)

          klass = tables[row.table].constantize
          mname = klass.send("#{TABLE_METHOD_NAME}_method")
          klass.send(mname, row)
        rescue StandardError => e
          log('Unexpected Error in ReplServer.check', err: e)
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

      errs.each { |msg| log(msg) }

      errs.empty?
    end

    def log(msg, err: nil)
      Koyo::Repl::PostgresServer.log(msg, err: err)
    end

    def self.log(msg, err: nil)
      Koyo::Repl::Log.log_repl(msg, err: err)
    end

    # Finds all models that that implement 'self.koyo_repl_handler'
    # This is only run once - during server spin up
    def self.tables_that_handle_koyo_replication
      return @@tables if @@tables.present?
      method_name = TABLE_METHOD_NAME
      log("Init: Finding models that support #{method_name}")
      tables = {}
      ActiveRecord::Base.connection.tables.map do |model|
        klass_name = model.capitalize.singularize.camelize
        klass = klass_name.constantize
        next unless klass.methods.include?(method_name)

        tables[klass.table_name] = klass_name
      rescue NameError # filters out stuff like SchemaMigration
        log("Init: ignoring model #{klass_name}")
      rescue StandardError => e
        log('Unexpected Error in '\
            'ReplServer.tables_that_handle_koyo_replication',
            err: e)
      end
      tables.each do |t|
        log("Init: registering handler #{t}")
      end
      @@tables = tables
      @@tables
    end
  end
end
