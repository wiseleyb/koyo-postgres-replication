# frozen_string_literal: true

# Basic model example
class KoyoReplModelExample < ApplicationRecord
  include Koyo::Repl::Mod

  # register method for replication
  koyo_repl_handler :handle_replication

  # This is called when a row is created/updated/deleted
  # You don't want to do DB updates from this or you will likely
  # create an infinite loop
  # This needs to be REALLY fast if you have a lot of db traffic
  # For example: if you're doing something like calling an API from this
  # method you should async it (put it in Sidekiq, ActiveJob, etc)
  def self.handle_replication(row)
    puts row.to_yaml
  end
end
