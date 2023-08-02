# frozen_string_literal: true
# Include this for logging help
module Koyo::Repl::Log
  LOG_LEVELS = %w(debug info warn error fatal)

  def self.included(base)
    base.extend(ClassMethods)

    # do some hacky meta programming to create helper methods
    LOG_LEVELS.each do |lvl|
      define_method "log_repl_#{lvl}" do |message, data = {}|
        self.class.log_repl(message, data, log_level: lvl.to_sym)
      end
    end
  end

  module ClassMethods
    # do some hacky meta programming to create helper methods
    LOG_LEVELS.each do |lvl|
      define_method "log_repl_#{lvl}" do |message, data = {}|
        log_repl(message, data, log_level: lvl.to_sym)
      end
    end

    # @param [Hash] data to add to log message
    def log_repl(message, data = {}, log_level: :info)
      return if message.blank?
      return if Koyo::Repl.config.disable_logging

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
      return if Koyo::Repl.config.disable_logging
      logid = SecureRandom.hex(5)
      hash.each do |k, v|
        msg = "source=KoyoReplication logid=#{logid} level=#{log_level} "\
              "#{k}=#{v}"
        puts msg
        unless LOG_LEVELS.include?(log_level.to_s)
          raise "Invalid logger level. Valid options are #{LOG_LEVELS}"
        end
        Rails.logger.send(log_level, msg)
      end
      if Koyo::Repl.config.handler_klass
        Koyo::Repl.config.handler_klass.constantize
                  .koyo_log_event(hash, log_level)
      end
    end
  end
end
