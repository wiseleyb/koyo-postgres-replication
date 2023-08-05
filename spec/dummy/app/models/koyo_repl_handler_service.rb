# frozen_string_literal: true

# You can override these methods to do things like ping Slack, retart
# crashed things, handle errors, handle logging, handle all replicaiton events
# (instead of doing this in models)
class KoyoReplHandlerService < Koyo::Repl::EventHandlerService
  class << self
    # example row:
    # User.handle_replcation called
    # TODO: Add link to class returned

    # Called whenever an error is raised in Koyo::Repl code

    # log_level: :debug, :info, :warn, :error, :fatal
    # Example of message
    # source=KoyoReplication logid=d7f1f0bb2a
    #   message=Init: Finding models that support koyo_repl_handler
    # You can use this as a catch all for any log event or use methods
    # below if that's easier

    # Called whenever Rails.logger.debug is called from Koyo::Repl code

    # Called whenever Rails.logger.debug is called from Koyo::Repl code

    # Called whenever Rails.logger.debug is called from Koyo::Repl code

    # Called whenever Rails.logger.debug is called from Koyo::Repl code

    # Called whenever Rails.logger.debug is called from Koyo::Repl code
  end
end
