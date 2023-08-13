# frozen_string_literal: true

module Koyo
  module Repl
    # Basic utilities for postgres replication
    # @see Postgres doc for more options
    # https://www.postgresql.org/docs/9.4/logicaldecoding-example.html
    class Database
      class << self
        # TODO: refactor this out of the config class
        # DB connection name in config/database.yml. Defaults to Rails.env
        # (so standard connection on most rails app). We add this because you need
        # admin priveleges to use replication and some companies have problems with
        # this. Whatever this is called it will have Rails.env tacked on so if it's
        # replication - the connection would be "replciation_#{Rails.env}"
        def conn
          return @conn if @conn

          conn_name = Koyo::Repl.config.database_name

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

        # Reads from the replication slot.
        # Reading from this marks the rows read (so you won't see them again)
        # For testing you can use `peek_slot` if you want to - which will keep
        # the data in the slot. A known issue is that this slot can grow so
        # large that you it'll time out when trying to read from it. This is a
        # major downside of this approach. Please open an issue if you know a
        # solution.
        def read_slot!
          sql = %(
          SELECT *
          FROM pg_logical_slot_get_changes('#{config_slot}',
                                           NULL,
                                           NULL,
                                           'pretty-print',
                                           '1');
        )
          exec_sql(sql)
        end

        # Peeks at data in the replication-slot. Use this for debugging. This
        # will leave the data in the replication-slot. If
        # Configuration.test_mode=true the code will default to peek'ing
        # instead of reading.
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

        # Checks count of current slot
        def replication_slot_count
          sql = %(
          SELECT count(*)
          FROM pg_logical_slot_peek_changes('#{config_slot}',
                                            NULL,
                                            NULL,
                                            'pretty-print',
                                            '1');
        )
          exec_sql(sql).first['count'].to_i
        end

        # Checks to see if the replication slot exists
        def replication_slot_exists?
          sql = %(
          select count(*)
          from pg_replication_slots
          where
            slot_name = '#{config_slot}'
            and database = '#{current_db_name}'
            and plugin = 'wal2json'
        )
          exec_sql(sql).first['count'].to_i.positive?
        end

        # Returns all data for current replication slot.
        def replication_slot
          sql = %(
          select *
          from pg_replication_slots
          where plugin = 'wal2json'
          and slot_name = '#{config_slot}'
          and database = '#{current_db_name}'
        )
          exec_sql(sql).first
        end

        # Returns all replication slots on the system that support wal2json
        def replication_slots
          sql = %(
          select *
          from pg_replication_slots
          where plugin = 'wal2json'
        )
          exec_sql(sql)
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

        # Deletes replication slot. You need admin priveleges for this.
        def delete_replication_slot!
          return unless replication_slot_exists?

          sql = %(select pg_drop_replication_slot('#{config_slot}'))
          exec_sql(sql)
        end

        # Checks the wal_level - which should be "logical" if things are setup
        # properly. You can change the wal_level in postgres config. See the
        # README for details on on this. When you change this you need to
        # restart the postgres server
        def wal_level
          sql = %(show wal_level)
          exec_sql(sql).first['wal_level']
        end

        # Helper - just returns the configured database name being used. Can
        # be changed using Configuration.slot
        def current_db_name
          Rails.configuration.database_configuration[Rails.env]['database']
        end

        # Runs SQL commands
        def exec_sql(sql)
          # ActiveRecord::Base.connection.execute(sql)
          conn.execute(sql)
        end

        # wrap this to support faster JSON parsing in the future
        def parse_json(json)
          JSON.parse(json)
        end

        def config_slot
          Koyo::Repl.config.slot
        end

        def to_bool(val)
          %w[1 true t yes].include?(val.to_s.downcase.strip)
        end
      end
    end
  end
end
