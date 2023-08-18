# Koyo::Postgres::Replication

例 rei - Japanese for example 
効用 koyo - Japanese for utility

## Replcation slots

This gem tries to simplify dealing with a `replication slot` in Postgres. 

### What is a replication slot?

Please see [the wiki page that discusses replication
slots](https://github.com/wiseleyb/koyo-postgres-replication/wiki/What-is-replication%3F)

### Why would you use this?

Example: You have a no-sql store (like Elastic-Search) that needs to be in-sync
with your database. You could do this "the Rails way" with `after-save` type
patterns. You could do this with a service type architecture that updates
things. But if you have non-rails teams updating data, or ever update the
database via SQL, this becomes more complex, duplicates delicate/error-prone
work between teams, or just isn't possible. Going the microservice approach
also isn't ideal for performance reasons (you never want to updating a really
busy DB via API). 

Please see [the
wiki](https://github.com/wiseleyb/koyo-postgres-replication/wiki/What-is-replication%3F)
for more discussion on this.

## Quick Start

You need to configure Postgres for this first. This isn't enabled by default.
See [Configuring Postgres for Replication in the
wiki](https://github.com/wiseleyb/koyo-postgres-replication/wiki/Configuring-Postgres-for-Replication)

Add to Gemfile:

```
gem 'koyo-postgres-replication'
```

Then:

```
bundle install
bundle exec rake koyo:repl:install
```

This adds files:

* `config/initializers/koyo_postgres_replication_config.rb`: which is commented
  on various ways to override various settings.
* `app/models/koyo_repl_handler_service.rb`: which has call backs for every
  replication event, log events, and errors. This file is also heavily
commented.
* `app/models/koyo_repl_model_example.rb`: is an example of how to add
  replication monitoring on a model level. You can delete this file - it's just
there for a simple example. 

### Run Diagnostics

You need to create a replication slot for each database. This requires admin
access. In
[config](https://github.com/wiseleyb/koyo-postgres-replication/blob/main/lib/koyo/repl/templates/koyo_postgres_replication_config.txt)
you can setup a separate `config/database.yml` connection to limit admin level
postgres access if your company prefers that.

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

Now - when you create/update/delete data in the configured database you should
be getting callbacks in
`app/models/koyo_repl_handler_service.rb#koyo_handle_all_replication(row)` and
in any model `app/models/{some-model}#handle_replication(row)` that implements
callbacks.

# Row data in callbacks

See [wiki page on DataRow for raw data examples of what you get from
Postgres](https://github.com/wiseleyb/koyo-postgres-replication/wiki/Koyo::Repl::DataRow-data-spec)

# Processing callbacks

Both `koyo_repl_handler_service#koyo_handle_all_replication(row)` and
`{some-model}#handle_replication(row)` need to be REALLY fast. You shouldn't do
database updates from this code (or risk infinite loops) and, if you're doing
something like updating an API you should async that via Sidekiq, ActiveJob,
etc. Keep in mind that, if you're running multiple Sidekiq servers that things
might not be processed in the same order. Please see the [wiki page on
processing
callbacks](https://github.com/wiseleyb/koyo-postgres-replication/wiki/Processing-callbacks)
for more on this.

# Testing

The following assumes you're using rspec (open to PRs supporting other test
frameworks though - I just don't use those)

By default (and definitely the fastest way) specs run inside
transactions that are rolled back after each spec runs. You need to use
[Database Cleaner](https://github.com/DatabaseCleaner/database_cleaner)
truncation approach to test this stuff. Please see the wiki on
[testing](https://github.com/wiseleyb/koyo-postgres-replication/wiki/Testing)
for what's needed if you want to run replication slot tests.

# Sample apps

These are simple Rails version-specific demo apps with Docker files

* [Rails 7 Example](https://github.com/wiseleyb/rei-postgres-replication/tree/rails-7-example)
* Rails 6 Example: coming soon
* Rails 5 Example: coming soon
* Rails 4 Example: coming soon
* Rails 3 Example: probably won't do
 
# Technical 

See wiki page on [creating this
gem](https://github.com/wiseleyb/koyo-postgres-replication/wiki/Creating-this-GEM)
if you're interested how to do gems like these.

## Working with the gem

See wiki page on [working with this
gem](https://github.com/wiseleyb/koyo-postgres-replication/wiki/Developing-on-this-GEM)
for basics of debugging and working with.

## Working with replication slots

See
[koyo::repl::database](https://github.com/wiseleyb/koyo-postgres-replication/blob/main/lib/koyo/repl/database.rb)
for sql examples on how to interact with replication slots.

## Yard Doc

Cheat sheets:
* https://gist.github.com/chetan/1827484
* https://kapeli.com/cheat_sheets/Yard.docset/Contents/Resources/Documents/index

Build yard docs: `yard`
View docs: `yard server` then open https://localhost:8808

# Contributing

TODO: update

* follow github guide
* run/add specs
* run rubocop
* add/run yard

# Working with gem

## Gem Build

```
rm koyo-postgres-replication-{current version}.gem
git add .
gem build
```

# TODO

* add monitoring helpers
* add support for multiple primary keys
* add badges like in https://raw.githubusercontent.com/rubocop/rubocop/master/README.md
