# Koyo::Postgres::Replication

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
