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


TODO:
* add generators/install
* figure out better logging options
* add monitoring helpers
* add diagnostic tool (checks permissions, postgres, etc)
