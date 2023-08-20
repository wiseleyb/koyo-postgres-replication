# frozen_string_literal: true

# This is used as an example for testing composite keys in postgres for tables
# that don't follow Rails opinionated standards. This is a terrible way to do
# this in Rails but the koyo:repl gem might need to deal with non-rails team
# generate tables.
#
# This uses the [composite primary keys
# gem](https://github.com/composite-primary-keys/composite_primary_keys) since
# Rails doesn't support this kind of thing.
class UserInterestsNonRail < ApplicationRecord
  include Koyo::Repl::Mod

  # requires [composite primary keys
  # gem](https://github.com/composite-primary-keys/composite_primary_keys)
  self.primary_keys = :user_id, :interest_id

  # register method for replication
  koyo_repl_handler :handle_replication

  # This is called when a row is created/updated/deleted
  # You don't want to do DB updates from this or you will likely
  # create an infinite loop
  # This needs to be REALLY fast if you have a lot of db traffic
  # For example: if you're doing something like calling an API from this
  # method you should async it (put it in Sidekiq, ActiveJob, etc)
  # @param row is a Koyo::Repl::DataRow
  # See Gem documentation for more info
  # https://github.com/wiseleyb/koyo-postgres-replication
  def self.handle_replication(row)
    # puts row.to_yaml
  end
end
