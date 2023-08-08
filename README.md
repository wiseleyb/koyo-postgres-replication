# Koyo::Postgres::Replication

## Quick Start

I'd recommend using the Docker method (see below) but for a plain Rails-7 project

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

# runs basic diagnostics - look for Error in this list and fix any issues
bundle exec rake koyo:repl:diagnostics

# run the server
bundle exec rake koyo:repl:run_server

# You should now be getting replication events in
# app/models/koyo_repl_handler_server.rb#koyo_handle_all_replication(row)
# when you create/update/delete any record

# You should see output in the server window when you change database rows
```

## Technical 

Created initial gem with

```
rails plugin new koyo-postgres-replication \
    --mountable \
    --skip-test \
    --dummy_path=spec/dummy \
    --skip-action-mailer \
    --skip-action-mailbox \
    --skip-action-text \
    --skip-active-job \
    --skip-active-storage \
    --skip-action-cable \
    --skip-asset-pipeline \
    --skip-javascript \
    --skip-hotwire \
    --skip-jbuilder \
    --no-api
```

Guide: https://www.hocnest.com/blog/testing-an-engine-with-rspec/

bundle console


## Yard

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
