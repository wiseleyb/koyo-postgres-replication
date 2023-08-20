# Koyo Postgres Replication Changelog

## 0.1.4.pre

- Add link to
  [doc](https://rubydoc.info/github/wiseleyb/koyo-postgres-replication/main) in
README
- Fix issues around composite keys (multiple primary keys) [Issues
  4](https://github.com/wiseleyb/koyo-postgres-replication/issues/4)

## 0.1.3.pre

- republishing yanked gem

## 0.1.2.pre

- bump TargetRubyVersion for Rubocop to 3.2.2
- fix [Issue
  2](https://github.com/wiseleyb/koyo-postgres-replication/issues/2) - gemspec
config around Yard doc
- Enter retry loop instead of crashing when db connection goes away

## 0.1.1.pre

- remove deprecated has_rdoc from gem spec
- fix [Issue 1](https://github.com/wiseleyb/koyo-postgres-replication/issues/1)
  - remove recursive run, replace with simple loop

## 0.1.0.pre

- rails 7 plugin
- postgres replication monitor
- install script 
- documentation
- basic specs
- example rails project
- diagnostic tools
- utility class for working with replication slots
- functional - but not tested in real life yet

