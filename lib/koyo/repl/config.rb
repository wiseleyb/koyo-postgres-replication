module Koyo::Repl
  class Config
    class << self
      # Try to auto create replication slot if it doesn't exist
      def auto_create_replication_slot?
        true
      end

      # Since replication operations require admin priveleges
      # this allows you to specificy something other than
      # Rails.env if needed
      def db_conn
        #conn_name = ENV['KOYO_REPL_DB_CONN_NAME'] || Rails.env
        conn_name = 'replicaiton'
        config =
          ApplicationRecord.configurations.find_db_config(conn_name)
        ActiveRecord::Base.establish_connection config
      end

      # Replication Slot name - can be any string
      def slot
        ENV['KOYO_REPL_SLOT'] || "koyo_repl_example_#{Rails.env}"
      end

      # Time to wait before checking Replication Slot again in seconds
      # Note: that if there 10,000 things on the replciation-queue it will
      # process all of those as fast as possible, then pause for this many
      # seconds before re-checking the replication-queue
      def sql_delay
        (ENV['KOYO_REPL_SQL_DELAY'] || 1).to_i
      end

      # When true we only "peek" the replication slot
      # Peek (when this is false):
      #   leaves the data on the postgres-replication queue
      # Read (when this is true):
      #   removes data from the postgres-replication queue
      def test_mode
        false
      end
    end
  end
end
