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

      # Checks if replication slot exists.
      # TODO: maybe this should create if it doesn't?
      def replication_slot_exists?
        Koyo::Repl::Database.replication_slot_exists?
      rescue StandardError => e
        "Error: #{e.message}"
      end

      # Returns list of models that have registered a call back
      def registered_tables
        res =
          Koyo::Repl::PostgresServer.tables_that_handle_koyo_replication || {}
        if res == {}
          res = {
            warning: 'No tables registered - see example file in '\
                     'app/models/koyo_repl_model_example.rb to see '\
                     'how to monitor replication for a table from a model. '\
                     'This is optional - you can just use '\
                     'app/models/koyo_repl_handler_service.rb as a catch all '\
                     'for all replication events if you want.'
          }
        end
        res
      rescue StandardError => e
        "Error: #{e.message}"
      end

      # Checks connection to database
      def can_connect?
        Koyo::Repl::Database.conn.execute('select now()')
        true
      rescue StandardError => e
        "Error: #{e.message}"
      end

      # Checks access/permissions to replication slot
      def can_access_replication_slot?
        Koyo::Repl::Database.peek_slot
        true
      rescue StandardError => e
        "Error: #{e.message}"
      end

      # Checks that replication slot exists
      def repl_count
        Koyo::Repl::Database.replication_slot_count
      rescue StandardError => e
        "Error: #{e.message}"
      end

      # Returns configured database name
      def adapter_name
        Koyo::Repl::Datasbase.conn.adapter_name
      rescue StandardError => e
        "Error: #{e.message}"
      end

      # Returns configured wal_level. Should be "logical"
      def wal_level
        Koyo::Repl::Database.wal_level
      rescue StandardError => e
        "Error: #{e.message}"
      end

      # Helper - outputs a hash
      def h_to_s(hash)
        hash.map { |k, v| "  #{k}: #{v}" }.join("\n")
      end
    end
  end
end
