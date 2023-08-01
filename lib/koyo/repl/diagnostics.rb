# frozen_string_literal: true
module Koyo::Repl
  # Provides state and debugging info for Repl setup
  # can be run with rake koyo::repl::diagnostics
  class Diagnostics
    # For use with rake koyo::repl::diagnostics
    # Outputs repl setup and current state info
    def rake_info
      msg = []
      msg << "Config settings: \n#{h_to_s(Koyo::Repl.config.to_h)}"
      msg << "Replication slot exists: #{replication_slot_exists?}"
      msg << "Registered tables: \n#{h_to_s(registered_tables)}"
      msg << "Can connect to db: #{can_connect?}"
      msg << "Can access replication slot: #{can_access_replication_slot?}"
      msg << "Replication slot count: #{repl_count}"
      msg
    end

    def replication_slot_exists?
      Koyo::Repl::Utils.replication_slot_exists?
    rescue => err
      "Error: #{err.message}"
    end

    def registered_tables
      Koyo::Repl::PostgresServer.tables_that_handle_koyo_replication || {}
    rescue => err
      "Error: #{err.message}"
    end

    def can_connect?
      Koyo::Repl.config.db_conn.execute('select now()')
      true
    rescue => err
      "Error: #{err.message}"
    end

    def can_access_replication_slot?
      Koyo::Repl::Utils.peek_slot
      true
    rescue => err
      "Error: #{err.message}"
    end

    def repl_count
      Koyo::Repl::Utils.replication_slot_count
    rescue => err
      "Error: #{err.message}"
    end


    def h_to_s(h)
      h.map {|k, v| "  #{k}: #{v}"}.join("\n")
    end
  end
end
