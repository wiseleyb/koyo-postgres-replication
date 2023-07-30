# Used to support model/table level replication handlers
#
# Example:
=begin
  class User < ApplicationRecord
    include Koyo::Repl::Mod

    # register method for replication
    koyo_repl_handler :handle_replication

    # This is called when a row is created/updated/deleted
    # You don't want to do DB updates from this or you will likely
    # create an infinite loop
    def self.handle_replication(row)
      msg = [
        '*' * 80,
        row.to_yaml,
        '*' * 80
      ]
      puts msg
    end
  end
=end
module Koyo::Repl::Mod
  def self.included(base)
    base.extend(ClassMethods)
  end
  module ClassMethods
    attr_accessor :koyo_repl_handler_method

    def koyo_repl_handler(n)
      @koyo_repl_handler_method = n
    end
  end
end
