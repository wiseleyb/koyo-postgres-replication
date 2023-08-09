# Koyo::Postgres::Replication

## Replcation slots

This gem tries to simplify dealing with a `replication slot` in Postgres. 

### What is a replication slot?

Please see [the wiki page that discusses replication slots](https://github.com/wiseleyb/koyo-postgres-replication/wiki/What-is-replication%3F)

### Why would you use these?

There are tons of reasons and tons of alternatives. 

Example: You have a no-sql store (like Elastic-Search) that needs to be in-sync with your database. You could do this "the Rails way" with `after-save` type patterns. You could do this with a service type architecture that updates things. But if you have non-rails teams updating data, this becomes more complex. Please see [the wiki](https://github.com/wiseleyb/koyo-postgres-replication/wiki/What-is-replication%3F) for more discussion on this.

## Quick Start

Add to Gemfile:

```
gem 'koyo-postgres-replication', 
    git: 'https://github.com/wiseleyb/koyo-postgres-replication',
    require: 'koyo'
```

Then:

```
bundle install
bundle exec rake koyo:repl:install
```

This adds files:

* `config/initializers/koyo_postgres_replication_config.rb`: which is commented on various ways to override various settings.
* `app/models/koyo_repl_handler_service.rb`: which has call backs for every replication event, log events, and errors. This file is also heavily commented.
* `app/models/koyo_repl_model_example.rb`: is an example of how to add replication monitoring on a model level. You can delete this file - it's just there for a simple example. 

### Run Diagnostics

You need to create a replication slot for each database. This requires admin access. In [config](https://github.com/wiseleyb/koyo-postgres-replication/blob/main/lib/koyo/repl/templates/koyo_postgres_replication_config.txt) you can setup a separate `config/database.yml` connection to limit admin level postgres access if your company prefers that.

```
# runs basic diagnostics - look for Error in this list and fix any issues
bundle exec rake koyo:repl:diagnostics
```

Which will output something like:

```
--------------------------------------------------------------------------------
Koyo::Repl::Diagnostic
source=KoyoReplication logid=f3a8f68d3e level=info message=Init: Finding models that support koyo_repl_handler
source=KoyoReplication logid=410b6fd0d0 level=info message=Init: ignoring model SchemaMigration
source=KoyoReplication logid=b429e47251 level=info message=Init: ignoring model ArInternalMetadatum
source=KoyoReplication logid=6532a8ec76 level=info message=Init: registering handler ["users", "User"]
Config settings:
  auto_create_replication_slot: true
  config_prefix: KOYO_REPL
  db_conn:
  slot: koyo_repl_rei_postgres_replication_development_development
  sql_delay: 1
  test_mode: false
Replication slot exists: true
Registered tables:
  users: User
Can connect to db: true
Connection adapter: PostgreSQL
Wal Level (should be 'logical'): logical
Can access replication slot: true
Replication slot count: 0
--------------------------------------------------------------------------------
```

If there are errors you'll need to fix those first before running the server.

### Run the server

```
bundle exec rake koyo:repl:run_server
```

Now - when you create/update/delete data in the configured database you should be getting callbacks in `app/models/koyo_repl_handler_service.rb#koyo_handle_all_replication(row)` and in any model `app/models/{some-model}#handle_replication(row)` that implements callbacks.

# Row data in callbacks

# Processing callbacks

Both `koyo_repl_handler_service#koyo_handle_all_replication(row)` and `{some-model}#handle_replication(row)` need to be REALLY fast. You shouldn't do database updates from this code (or risk infinite loops) and, if you're doing something like updating an API you should async that via Sidekiq, ActiveJob, etc. Keep in mind that, if you're running multiple Sidekiq servers that things might not be processed in the same order. Please see the [wiki page on processing callbacks](https://github.com/wiseleyb/koyo-postgres-replication/wiki/Processing-callbacks) for more on this.

# Testing

By default (and definitely the fastest was to run specs) specs run inside transactions that are rolled back after each spec runs. You need to use [Database Cleaner](https://github.com/DatabaseCleaner/database_cleaner) truncation approach to test this stuff. Please see the wiki on [testing](https://github.com/wiseleyb/koyo-postgres-replication/wiki/Testing) for what's needed if you want to run replication slot tests.

# Sample apps

These are simple Rails version-specific demo apps with Docker files

* [Rails 7 Example]()
* Rails 6 Example: coming soon
* Rails 5 Example: coming soon
* Rails 4 Example: coming soon
* Rails 3 Example: probably won't do
 
# Rails versions

`main` is always the latest but there are branches with Rails specific versions

TODO: flush this out

# Technical 

See wiki page on [creating this gem](https://github.com/wiseleyb/koyo-postgres-replication/wiki/Creating-this-GEM) if you're interested how to do gems like these.

## Working with the gem

See wiki page on [working with this gem](https://github.com/wiseleyb/koyo-postgres-replication/wiki/Developing-on-this-GEM) for basics of debugging and working with.

## Yard Doc

Cheat sheets:
* https://gist.github.com/chetan/1827484
* https://kapeli.com/cheat_sheets/Yard.docset/Contents/Resources/Documents/index

Build yard docs: `yard`
View docs: `yard server` then open https://localhost:8808


# TODO

* add generators/install
* figure out better logging options
* add monitoring helpers
* add diagnostic tool (checks permissions, postgres, etc)
* [yard docs](https://gnuu.org/2009/11/21/generate-yard-docs-for-your-gem/)
* add badges like in https://raw.githubusercontent.com/rubocop/rubocop/master/README.md
