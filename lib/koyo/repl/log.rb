# frozen_string_literal: true

# Include this for logging help
module Koyo
  module Repl
    # Log helper tools. Include this in your class to use
    module Log
      LOG_LEVELS = %w[debug info warn error fatal].freeze

      def self.included(base)
        base.extend(ClassMethods)

        # do some hacky meta programming to create helper methods
        LOG_LEVELS.each do |lvl|
          define_method "log_repl_#{lvl}" do |message, data = {}|
            self.class.log_repl(message, data, log_level: lvl.to_sym)
          end
        end
      end

      # Instance level methods
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
          data[:message] ||= message

          log_repl_hash(data, log_level)
        end

        # logs messages
        # adds a short guid for tracking multiple messages
        def log_repl_hash(hash, log_level)
          return if Koyo::Repl.config.disable_logging

          logid = SecureRandom.hex(5)

          hash.each do |k, v|
            log_repl_key_value(logid, log_level, k, v)
          end
        end

        def log_repl_key_value(logid, log_level, key, val)
          msg = "source=KoyoReplication logid=#{logid} level=#{log_level} "\
                "#{key}=#{val}"
          puts msg
          check_log_level(log_level)
          Rails.logger.send(log_level, msg)
          Koyo::Repl::EventHandlerService.koyo_log_event(msg, log_level)
          Koyo::Repl::EventHandlerService.send("koyo_log_event_#{log_level}",
                                               msg)
        end

        def check_log_level(log_level)
          return if LOG_LEVELS.include?(log_level.to_s)

          raise "Invalid logger level. Valid options are #{LOG_LEVELS}"
        end
      end
    end
  end
end
