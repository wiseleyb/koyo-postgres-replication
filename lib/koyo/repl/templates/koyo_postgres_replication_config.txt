Koyo::Repl.configure do |config|
  # Create the replication slot if it doesn't exist. Defaults to true
  # You can set this with an ENV as well: 
  #   KOYO_REPL_AUTO_CREATE_REPLICATION_SLOT
  # config.auto_create_replication_slot = true

  # Allows you to override the prefix used if you're using ENV to configure
  # things. Defaults to KOYO_REPL
  # config.config_prefix = 'KOYO_REPL'

  # DB connection name in config/database.yml. Defaults to Rails.env
  # (so standard connection on most rails app). We add this because you need
  # admin priveleges to use replication and some companies have problems with
  # this. Whatever this is called it will have Rails.env tacked on so if it's
  # replication - the connection would be "replciation_#{Rails.env}"
  # You can set this with an ENV as well: 
  #   KOYO_REPL_DB_CONN
  # config.db_conn = 'replication'

  # Disable logging. Not recommended.
  # You can set this with an ENV as well: 
  #   KOYO_REPL_DISABLE_LOGGING
  # config.disable_logging = true

  # Determines the name of this replication slot. Defaults to
  # koyo_repl_{Rails.env}.
  # You can check replication slots that exist with:
  #
  #  select slot_name
  #  from pg_replication_slots
  #  where
  #    and plugin = 'wal2json'
  # You can set this with an ENV as well: 
  #   KOYO_REPL_SLOT
  # config.slot = "koyo_repl_#{Rails.env}"

  # Time to wait before checking Replication Slot again in seconds
  # Note: that if there 10,000 things on the replciation-queue it will
  # process all of those as fast as possible, then pause for this many
  # seconds before re-checking the replication-queue
  # You can set this with an ENV as well: 
  #   KOYO_REPL_SQL_DELAY
  # config.sql_delay = 1

  # When true we only "peek" the replication slot
  # Peek (when this is false):
  #   leaves the data on the postgres-replication queue
  # Read (when this is true):
  #   removes data from the postgres-replication queue
  # Defaults to false
  # You can set this with an ENV as well: 
  #   KOYO_REPL_TEST_MODE
  # config.test_mode = false
end
