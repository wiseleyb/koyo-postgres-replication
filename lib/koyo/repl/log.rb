# frozen_string_literal: true
module Koyo::Repl
  # Performns basic logging around replication
  class Log
    class << self
      # @param [Hash] data to add to log message
      def log_repl(message, data = {})
        return if message.blank?

        err = data.delete(:err)
        if err
          data[:err_message] ||= err.message
          data[:err_backtrace] ||= err.backtrace.join("\n")
        end

        h = {
          message:
        }.merge(data)

        log_hash(h)
      end

      # logs messages
      # adds a short guid for tracking multiple messages
      def log_hash(hash)
        logid = SecureRandom.hex(5)
        hash.each do |k, v|
          msg = "source=KoyoReplication logid=#{logid} #{k}=#{v}"
          puts msg if Rails.env.test?
          Rails.logger.info msg
        end
      end
    end
  end
end
