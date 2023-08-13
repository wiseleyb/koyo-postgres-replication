# frozen_string_literal: true

# Include this for logging help: include Koyo::Repl::Log
module Koyo
  module Repl
    # Log helper tools. Include this in your class to use
    module Log
      LOG_LEVELS = %w[debug info warn error fatal].freeze

      # Run when "include Koyo::Repl::Log" is called from including class
      def self.included(base)
        base.extend(ClassMethods)

        # Creates helper methods based on LOG_LEVELS
        LOG_LEVELS.each do |lvl|
          define_method "log_repl_#{lvl}" do |message, data = {}|
            self.class.log_repl(message, data, log_level: lvl.to_sym)
          end
        end
      end

      # Instance level methods
      module ClassMethods
        # Creates helper methods based on LOG_LEVELS
        LOG_LEVELS.each do |lvl|
          define_method "log_repl_#{lvl}" do |message, data = {}|
            log_repl(message, data, log_level: lvl.to_sym)
          end
        end

        # Log message and a hash with level
        # @param [String] message Arbitrary string to output
        # @param [Hash] data to add to log message. if :err is included this
        # will parse message and backtrace
        # @param [Symbol] log_level defaults to :info (LOG_LEVELS contains
        # other options
        def log_repl(message, data = {}, log_level: :info)
          return if message.blank?
          return if Koyo::Repl.config.disable_logging

          err = data.delete(:err)
          if err
            data[:err_message] ||= err.message
            data[:err_backtrace] ||= err.backtrace.join("\n")
          end
          data[:message] ||= message

          log_repl_hash(data, log_level)
        end

        # Logs messages with formating like:
        #   source=KoyoReplication
        #   logid=short guid for uniqueness if needed
        #   level=log_level
        #   {key}={value} data being logged
        # @param [Hash] hash keys/values being logged
        # @param [Symbol] log_level see LOG_LEVELS constant for options
        def log_repl_hash(hash, log_level)
          return if Koyo::Repl.config.disable_logging

          logid = SecureRandom.hex(5)

          hash.each do |k, v|
            log_repl_key_value(logid, log_level, k, v)
          end
        end

        # Logs message with formating like:
        #   source=KoyoReplication
        #   logid=short guid for uniqueness if needed
        #   level=log_level
        #   {key}={value} data being logged
        # @param [String] logid used incase uniqueness is required
        # @param [Symbol] log_level see contant LOG_LEVELS for options
        # @param [String] key any string to log
        # @param [String] val any string to log
        def log_repl_key_value(logid, log_level, key, val)
          msg = "source=KoyoReplication logid=#{logid} level=#{log_level} "\
                "#{key}=#{val}"
          puts msg unless Rails.env.test? # don't pollute test output
          check_log_level(log_level)
          Rails.logger.send(log_level, msg)
          Koyo::Repl::EventHandlerService.koyo_log_event(msg, log_level)
          Koyo::Repl::EventHandlerService.send("koyo_log_event_#{log_level}",
                                               msg)
        end

        # Validates log_level is in contant LOG_LEVELS
        # @param log_level to validate
        def check_log_level(log_level)
          return if LOG_LEVELS.include?(log_level.to_s)

          raise "Invalid logger level. Valid options are #{LOG_LEVELS}"
        end
      end
    end
  end
end
