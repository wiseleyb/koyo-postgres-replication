Koyo::Repl.configure do |config|
  # Create the replication slot if it doesn't exist. Defaults to true
  # config.auto_create_replication_slot = true

  # You can configure a default catch all class that will be called for
  # all replication events. This can be used in combination with model level
  # calls. The class must support koyo_handle_all_replication(row) method.
  # Example:
  #   class CatchAll
  #     def self.koyo_handle_all_replication(row); end
  #   end
  config.handler_klass = 'KoyoReplHandlers'

  # Allows you to override the prefix used if you're using ENV to configure
  # things. Defaults to KOYO_REPL
  # config.config_prefix = 'KOYO_REPL'

  # DB connection name in config/database.yml. Defaults to Rails.env
  # (so standard connection on most rails app). We add this because you need
  # admin priveleges to use replication and some companies have problems with
  # this. Whatever this is called it will have Rails.env tacked on so if it's
  # replication - the connection would be "replciation_#{Rails.env}"
  config.db_conn = 'replication'

  # Determines the name of this replication slot. Defaults to
  # koyo_repl_{Rails.env}.
  # You can check replication slots that exist with:
  #
  #  select slot_name
  #  from pg_replication_slots
  #  where
  #    and plugin = 'wal2json'
  # config.slot = "koyo_repl_#{Rails.env}"

  # Time to wait before checking Replication Slot again in seconds
  # Note: that if there 10,000 things on the replciation-queue it will
  # process all of those as fast as possible, then pause for this many
  # seconds before re-checking the replication-queue
  # config.sql_delay = 1

  # When true we only "peek" the replication slot
  # Peek (when this is false):
  #   leaves the data on the postgres-replication queue
  # Read (when this is true):
  #   removes data from the postgres-replication queue
  # Defaults to false
  # config.test_mode = false
end
