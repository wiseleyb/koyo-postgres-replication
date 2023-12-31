# frozen_string_literal: true

module Koyo
  module Repl
    # Class wrapper for replication data pulls
    #   Example data packet
    #
    #   {
    #   "change": [
    #     {
    #       "kind": "update",
    #       "schema": "public",
    #       "table": "users",
    #       "columnnames": ["id", "email", ...],
    #       "columntypes": ["integer", "character varying(255)", ...],
    #       "columnvalues": [120665, "", ...]
    #       "oldkeys": {
    #         "keynames": ["id"],
    #         "keytypes": ["integer"],
    #         "keyvalues": [120665]
    #       }
    #     }
    #   ]
    # }
    class Data
      attr_accessor :row, # raw results from db
                    :lsn, # ???
                    :xid  # uniq id of row returned

      # Takes a row from ReplDatabase.(peek_slot/read_slot!)
      # @see For details on `row` see:
      # https://github.com/wiseleyb/koyo-postgres-replication/wiki/Koyo::Repl::DataRow-data-spec
      def initialize(row)
        @row = row
        @lsn = row['lsn']
        @xid = row['xid']
        # TODO: find faster JSON lib for this
        @data_rows = Koyo::Repl::Database.parse_json(row['data'])['change']
      end

      # Collection of Koyo::Repl::DataRow
      #
      # When you read from a replicaiton slot it can return 0-n change
      # events. In general this system works on a row based level,
      # which is a bit slower but is simpler to code.
      def rows
        # @data_rows.map { |d| ReplDataRow.new(xid, d) }
        @data_rows.map { |d| Koyo::Repl::DataRow.new(d) }
      end
    end
  end
end
