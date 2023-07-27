# frozen_string_literal: true

module Koyo::Repl
  # Basic utilities for postgres replication
  # Doc https://www.postgresql.org/docs/9.4/logicaldecoding-example.html
  class Utils
    class << self
      # Reads from the replication slot.
      # Reading from this marks the rows read (so you won't see them again)
      # For testing you can `peek_slot` if you want to - which will keep the data
      # in the slot
      def read_slot!
        sql = %(
          SELECT *
          FROM pg_logical_slot_get_changes('#{config_slot}',
                                           NULL,
                                           NULL,
                                           'pretty-print',
                                           '1')
        )
        exec_sql(sql)
      end

      # Peeks at data in the replication-slot. Use this for debugging. This
      # will leave the data in the replication-slot
      def peek_slot
        sql = %(
          SELECT *
          FROM pg_logical_slot_peek_changes('#{config_slot}',
                                            NULL,
                                            NULL,
                                            'pretty-print',
                                            '1');
        )
        exec_sql(sql)
      end

      # Checks to see if the replication slot exists
      def replication_slot_exists?
        sql = %(
          select count(*)
          from pg_replication_slots
          where
            slot_name = '#{config_slot}'
            and plugin = 'wal2json'
        )
        exec_sql(sql).first['count'].to_i.positive?
      end

      # Creates a replication slot. You need admin priveleges for this.
      def create_replication_slot!
        return if replication_slot_exists?

        sql = %(
          SELECT 'init'
          FROM pg_create_logical_replication_slot('#{config_slot}',
                                                  'wal2json')
        )
        exec_sql(sql)
      end

      # Deletes replication slot
      def delete_replication_slot!
        return unless replication_slot_exists?

        sql = %(select pg_drop_replication_slot('#{config_slot}'))
        exec_sql(sql)
      end

      # Runs SQL commands
      def exec_sql(sql)
        ActiveRecord::Base.connection.execute(sql)
      end

      # wrap this to support faster JSON parsing in the future
      def parse_json(json)
        JSON.parse(json)
      end

      def config_slot
        Koyo::Repl::Config.slot
      end
    end
  end
end
