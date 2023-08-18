# frozen_string_literal: true

module Koyo
  module Repl
    # Supports config/initializer or ENV and adds defaults
    # lib/koyo/repl/templates/koyo_postges_replication_config is
    # copied to config/initializers when `rake koyo:repl:install` is
    # run. If you set the associated ENV it will override these settings.
    class Configuration
      attr_writer :auto_create_replication_slot,
                  :config_prefix,
                  :database_name,
                  :disable_logging,
                  :slot,
                  :sql_delay,
                  :test_mode

      # Try to auto create replication slot if it doesn't exist
      # Defaults to true
      # Override with ENV['KOYO_REPL_AUTO_CREATE_REPLICATION_SLOT']
      def auto_create_replication_slot
        val = @auto_create_replication_slot ||
              ENV["#{config_prefix}_AUTO_CREATE_REPLICATION_SLOT"] ||
              'true'
        Koyo::Repl::Database.to_bool(val)
      end

      # Overrides the default prefix of ENV variables
      # Override with ENV['KOYO_REPL_CONFIG_PREFIX']
      def config_prefix
        @config_prefix || ENV['KOYO_REPL_CONFIG_PREFIX'] || 'KOYO_REPL'
      end

      # Name of config/database.yml connection to use for replication
      #
      # Since this requires admin priveleges you might want to use
      # a different connection to prevent all rails actions having
      # admin priveleges to your DB. Default to whatever the default
      # DB is for the project
      # Override with ENV['KOYO_REPL_DB_CONN_NAME']
      def database_name
        @database_name || ENV["#{config_prefix}_DATABASE_NAME"]
      end

      # Disables logging (not recommended)
      # Defaults to false
      # Override with ENV['KOYO_REPL_DISABLE_LOGGING']
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
      #
      # Override with ENV['KOYO_REPL_SLOT']
      def slot
        @slot ||
          ENV["#{config_prefix}_SLOT"] ||
          "koyo_repl_#{Koyo::Repl::Database.current_db_name}_#{Rails.env}"
      end

      # Time to wait before checking Replication Slot again in seconds
      # Note: that if there 10,000 things on the replciation-queue it will
      # process all of those as fast as possible, then pause for this many
      # seconds before re-checking the replication-queue
      # Overide with ENV['KOYO_REPL_SQL_DELAY']
      def sql_delay
        @sql_delay || (ENV["#{config_prefix}_SQL_DELAY"] || 1).to_i
      end

      # When true we only "peek" the replication slot
      # Peek (when this is false):
      #   leaves the data on the postgres-replication queue
      # Read (when this is true):
      #   removes data from the postgres-replication queue
      # Defaults to false
      # Override with ENV['KOYO_REPL_TEST_MODE']
      def test_mode
        val = @test_mode || ENV["#{config_prefix}_TEST_MODE"]
        Koyo::Repl::Database.to_bool(val)
      end

      # Helper method that converts config settings into a hash
      def to_h
        {
          auto_create_replication_slot:,
          config_prefix:,
          database_name:,
          slot:,
          sql_delay:,
          test_mode:
        }
      end

      # Helper method that converts config settings into a string
      def to_s
        to_h.map { |k, v| "#{k}: #{v}" }.join("\n")
      end
    end
  end
end
