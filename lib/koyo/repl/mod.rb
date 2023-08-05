# frozen_string_literal: true

module Koyo
  module Repl
    # Used to support model/table level replication handlers
    #
    # Example:
    #   class User < ApplicationRecord
    #     include Koyo::Repl::Mod
    #
    #     # register method for replication
    #     koyo_repl_handler :handle_replication
    #
    #     # This is called when a row is created/updated/deleted
    #     # You don't want to do DB updates from this or you will likely
    #     # create an infinite loop
    #     def self.handle_replication(row)
    #       msg = [
    #         '*' * 80,
    #         row.to_yaml,
    #         '*' * 80
    #       ]
    #       puts msg
    #     end
    #   end
    module Mod
      def self.included(base)
        base.extend(ClassMethods)
      end

      # Enables `koyo_repl_handler :handle_replication`
      module ClassMethods
        attr_accessor :koyo_repl_handler_method

        def koyo_repl_handler(method_name)
          @koyo_repl_handler_method = method_name
        end
      end
    end
  end
end
