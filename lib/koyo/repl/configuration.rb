# frozen_string_literal: true

module Koyo
  module Repl
    # Supports config/initializer or ENV and adds defaults
    # lib/koyo/repl/templates/koyo_postges_replication_config is
    # copied to config/initializers when `rake koyo:repl:install` is
    # run.
    class Configuration
      attr_writer :auto_create_replication_slot,
                  :config_prefix,
                  :db_conn,
                  :disable_logging,
                  :slot,
                  :sql_delay,
                  :test_mode

      # Try to auto create replication slot if it doesn't exist
      # Defaults to true
      def auto_create_replication_slot
        val = @auto_create_replication_slot ||
              ENV["#{config_prefix}_AUTO_CREATE_REPLICATION_SLOT"] ||
              'true'
        Koyo::Repl::Database.to_bool(val)
      end

      # Overrides the default prefix of ENV variables
      def config_prefix
        @config_prefix || ENV['KOYO_REPL_CONFIG_PREFIX'] || 'KOYO_REPL'
      end

      # Name of config/database.yml connection to use for replication
      #
      # Since this requires admin priveleges you might want to use
      # a different connection to prevent all rails actions having
      # admin priveleges to your DB. Default to whatever the default
      # DB is for the project
      def db_conn_name
        @db_conn || ENV["#{config_prefix}_DB_CONN_NAME"]
      end

      # TODO: refactor this out of the config class
      # DB connection name in config/database.yml. Defaults to Rails.env
      # (so standard connection on most rails app). We add this because you need
      # admin priveleges to use replication and some companies have problems with
      # this. Whatever this is called it will have Rails.env tacked on so if it's
      # replication - the connection would be "replciation_#{Rails.env}"
      def db_conn
        return @conn if @conn

        conn_name = db_conn_name

        unless conn_name
          @conn = ActiveRecord::Base.connection
          return @conn
        end

        conn_name = "#{conn_name}_#{Rails.env}"

        msg = "source=KoyoReplication Connecting to #{conn_name}"
        Rails.logger.info msg

        config =
          ApplicationRecord.configurations.find_db_config(conn_name)
        ActiveRecord::Base.establish_connection config
        @conn = ActiveRecord::Base.connection
        @conn
      end

      # Disables logging (not recommended)
      # Defaults to false
      def disable_logging
        Koyo::Repl::Database.to_bool(@disable_logging ||
          ENV["#{config_prefix}_DISABLE_LOGGING"])
      end

      # Replication Slot name - can be any string - but must be
      # unique to your database server.
      #
      # This is the name of the replication slot in postgres
      # You can check replication slots that exist with:
      #
      #  select slot_name
      #  from pg_replication_slots
      #  where
      #    and plugin = 'wal2json'
      def slot
        @slot ||
          ENV["#{config_prefix}_SLOT"] ||
          "koyo_repl_#{Koyo::Repl::Database.current_db_name}_#{Rails.env}"
      end

      # Time to wait before checking Replication Slot again in seconds
      # Note: that if there 10,000 things on the replciation-queue it will
      # process all of those as fast as possible, then pause for this many
      # seconds before re-checking the replication-queue
      def sql_delay
        @sql_delay || (ENV["#{config_prefix}_SQL_DELAY"] || 1).to_i
      end

      # When true we only "peek" the replication slot
      # Peek (when this is false):
      #   leaves the data on the postgres-replication queue
      # Read (when this is true):
      #   removes data from the postgres-replication queue
      # Defaults to false
      def test_mode
        val = @test_mode || ENV["#{config_prefix}_TEST_MODE"]
        Koyo::Repl::Database.to_bool(val)
      end

      # Helper method that converts config settings into a hash
      def to_h
        {
          auto_create_replication_slot: auto_create_replication_slot,
          config_prefix: config_prefix,
          db_conn: db_conn_name,
          slot: slot,
          sql_delay: sql_delay,
          test_mode: test_mode
        }
      end

      # Helper method that converts config settings into a string
      def to_s
        to_h.map { |k, v| "#{k}: #{v}" }.join("\n")
      end
    end
  end
end
