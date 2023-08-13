# frozen_string_literal: true

module Koyo
  module Repl
    # Class wrapper for replication row row
    # @see
    # https://github.com/wiseleyb/koyo-postgres-replication/wiki/Koyo::Repl::DataRow-row-spec
    # @see For details on row
    class DataRow
      attr_accessor :row,           # raw json of row - see example below
                    :kind,          # insert/update/delete
                    :schema,        # always public for this - not needed
                    :table,         # table being changed
                    :id,            # table.id
                    :id_type,       # integer/uuid
                    :columns,       # all columns from table - array
                    :column_types,  # all types of columns - array
                    :values         # all values from table - array

      # Initialized attributes
      def initialize(row)
        @row = row
        @kind = @row['kind']
        @schema = @row['schema']
        @table = @row['table']
        @columns = @row['columnnames']
        @column_types = @row['columntypes']
        @values = @row['columnvalues']
        check_set_primary_keys
      end

      # This doesn't work for multiple primary keys right now
      #
      # WARN: this breaks for multiple primary keys
      def check_set_primary_keys
        if @row['oldkeys']
          if @row['oldkeys']['keynames'].size > 1
            raise "This doesn't support multiple keys right now"
          end

          @id = @row['oldkeys']['keyvalues'].first
          @id_type = @row['oldkeys']['keytypes'].first
        else
          @id = val(:id)
          @id_type = type(:id)
        end
      end

      # Gets a value for a name from columnsvalues
      # @param name column name
      def val(name)
        values[columns.index(name.to_s)]
      end

      # Get a val type from columntypes
      # @param name column name
      def type(name)
        column_types[columns.index(name.to_s)]
      end
    end
  end
end

#   Example row packet
#
#   {
#   "change": [
#     {
#       "kind": "delete",
#       "schema": "public",
#       "table": "users",
#       "oldkeys": {
#         "keynames": ["id"],
#         "keytypes": ["integer"],
#         "keyvalues": [123]
#       }
#     },
#     {
#       "kind": "insert",
#       "schema": "public",
#       "table": "users",
#       "columnnames": ["id", "name", "email", ...],
#       "columntypes": ["integer", "character varying", ...],
#       "columnvalues": [234, "User", ...]
#     },
#     {
#       "kind": "update",
#       "schema": "public",
#       "table": "users",
#       "columnnames": ["id", "name", "email", ...],
#       "columntypes": ["integer", "character varying", ...],
#       "columnvalues": [234, "User", ...]
#       "oldkeys": {
#         "keynames": ["id"],
#         "keytypes": ["integer"],
#         "keyvalues": [233]
#       }
#     }
#   ]
# }
