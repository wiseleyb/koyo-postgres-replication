# frozen_string_literal: true

module Koyo
  module Repl
    # Provides state and debugging info for Repl setup
    # can be run with rake koyo::repl::diagnostics
    class Diagnostics
      # For use with rake koyo::repl::diagnostics
      # Outputs repl setup and current state info
      def rake_info
        [
          "Config settings: \n#{h_to_s(Koyo::Repl.config.to_h)}",
          "Replication slot exists: #{replication_slot_exists?}",
          "Registered tables: \n#{h_to_s(registered_tables)}",
          "Can connect to db: #{can_connect?}",
          "Connection adapter: #{adapter_name}",
          "Wal Level (should be 'logical'): #{wal_level}",
          "Can access replication slot: #{can_access_replication_slot?}",
          "Replication slot count: #{repl_count}"
        ]
      end

      def replication_slot_exists?
        Koyo::Repl::Utils.replication_slot_exists?
      rescue StandardError => e
        "Error: #{e.message}"
      end

      def registered_tables
        Koyo::Repl::PostgresServer.tables_that_handle_koyo_replication || {}
      rescue StandardError => e
        "Error: #{e.message}"
      end

      def can_connect?
        Koyo::Repl.config.db_conn.execute('select now()')
        true
      rescue StandardError => e
        "Error: #{e.message}"
      end

      def can_access_replication_slot?
        Koyo::Repl::Utils.peek_slot
        true
      rescue StandardError => e
        "Error: #{e.message}"
      end

      def repl_count
        Koyo::Repl::Utils.replication_slot_count
      rescue StandardError => e
        "Error: #{e.message}"
      end

      def adapter_name
        Koyo::Repl.config.db_conn.adapter_name
      rescue StandardError => e
        "Error: #{e.message}"
      end

      def wal_level
        Koyo::Repl::Utils.wal_level
      rescue StandardError => e
        "Error: #{e.message}"
      end

      def h_to_s(hash)
        hash.map { |k, v| "  #{k}: #{v}" }.join("\n")
      end
    end
  end
end
