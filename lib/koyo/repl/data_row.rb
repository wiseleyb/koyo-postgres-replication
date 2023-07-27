# frozen_string_literal: true
module Koyo::Repl
  # Class wrapper for replication data row
  class DataRow
    attr_accessor :data,          # raw json of row - see example below
                  :kind,          # insert/update/delete
                  :schema,        # always public for this - not needed
                  :table,         # table being changed
                  :id,            # table.id
                  :id_type,       # integer/uuid
                  :columns,       # all columns from table - array
                  :column_types,  # all types of columns - array
                  :values         # all values from table - array

    def initialize(data)
      @data = data
      @kind = @data['kind']
      @schema = @data['schema']
      @table = @data['table']
      @columns = @data['columnnames']
      @column_types = @data['columntypes']
      @values = @data['columnvalues']

      # TODO: this breaks for multiple primary keys
      if @data['oldkeys']
        raise "This doesn't support multiple keys right now" if @data['oldkeys']['keynames'].size > 1

        @id = @data['oldkeys']['keyvalues'].first
        @id_type = @data['oldkeys']['keytypes'].first
      else
        @id = val(:id)
        @id_type = type(:id)
      end
    end

    # gets a value for a name from columnsvalues
    def val(name)
      values[columns.index(name.to_s)]
    end

    # get a val type from columntypes
    def type(name)
      column_types[columns.index(name.to_s)]
    end
  end
end

#   Example data packet
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
