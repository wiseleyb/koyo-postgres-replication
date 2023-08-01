# frozen_string_literal: true
# Include this for logging help
module Koyo::Repl::Log
  def self.included(base)
    base.extend(ClassMethods)
    def log_repl_debug(message, data = {})
      self.class.log_repl(message, data, log_level: :debug)
    end

    def log_repl_info(message, data = {})
      self.class.log_repl(message, data, log_level: :info)
    end

    def log_repl_warn(message, data = {})
      self.class.log_repl(message, data, log_level: :warn)
    end

    def log_repl_error(message, data = {})
      self.class.log_repl(message, data, log_level: :error)
    end
  end

  module ClassMethods
    def log_repl_debug(message, data = {})
      log_repl(message, data, log_level: :debug)
    end

    def log_repl_info(message, data = {})
      log_repl(message, data, log_level: :info)
    end

    def log_repl_warn(message, data = {})
      log_repl(message, data, log_level: :warn)
    end

    def log_repl_error(message, data = {})
      log_repl(message, data, log_level: :error)
    end

    # @param [Hash] data to add to log message
    def log_repl(message, data = {}, log_level: :info)
      return if message.blank?

      err = data.delete(:err)
      if err
        data[:err_message] ||= err.message
        data[:err_backtrace] ||= err.backtrace.join("\n")
      end

      h = {
        message:
      }.merge(data)

      log_repl_hash(h, log_level)
    end

    # logs messages
    # adds a short guid for tracking multiple messages
    def log_repl_hash(hash, log_level)
      logid = SecureRandom.hex(5)
      hash.each do |k, v|
        msg = "source=KoyoReplication logid=#{logid} #{k}=#{v}"
        puts msg
        case log_level
        when :debug
          Rails.logger.debug msg
        when :info
          Rails.logger.info msg
        when :warn
          Rails.logger.warn msg
        when :info
          Rails.logger.error msg
        end
      end
      if Koyo::Repl.config.handler_klass
        Koyo::Repl.config.handler_klass.constantize
                  .koyo_log_event(hash, log_level)
      end
    end
  end
end
