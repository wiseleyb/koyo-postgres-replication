# frozen_string_literal: true

# You can override these methods to do things like ping Slack, retart
# crashed things, handle errors, handle logging, handle all replicaiton events
# (instead of doing this in models)
class KoyoReplHandlerService < Koyo::Repl::EventHandlerService
  class << self
    # example row:
    # User.handle_replcation called
    # TODO: Add link to class returned
    def koyo_handle_all_replication(row); end

    # Called whenever an error is raised in Koyo::Repl code
    def koyo_error(err); end

    # log_level: :debug, :info, :warn, :error, :fatal
    # Example of message
    # source=KoyoReplication logid=d7f1f0bb2a
    #   message=Init: Finding models that support koyo_repl_handler
    # You can use this as a catch all for any log event or use methods
    # below if that's easier
    def koyo_log_event(message, log_level); end

    # Called whenever Rails.logger.debug is called from Koyo::Repl code
    def koyo_log_event_debug(message); end

    # Called whenever Rails.logger.debug is called from Koyo::Repl code
    def koyo_log_event_info(message); end

    # Called whenever Rails.logger.debug is called from Koyo::Repl code
    def koyo_log_event_warn(message); end

    # Called whenever Rails.logger.debug is called from Koyo::Repl code
    def koyo_log_event_error(message); end

    # Called whenever Rails.logger.debug is called from Koyo::Repl code
    def koyo_log_event_fatal(message); end
  end
end
