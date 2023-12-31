# frozen_string_literal: true

module Koyo
  # Main replication namespace
  module Repl
    require_relative 'koyo/repl/configuration'
    require_relative 'koyo/repl/data'
    require_relative 'koyo/repl/database'
    require_relative 'koyo/repl/data_row'
    require_relative 'koyo/repl/diagnostics'
    require_relative 'koyo/repl/event_handler_service'
    require_relative 'koyo/repl/install'
    require_relative 'koyo/repl/log'
    require_relative 'koyo/repl/mod'
    require_relative 'koyo/repl/postgres_server'
    require_relative 'koyo/repl/railtie' # if defined?(Rails)
    require_relative 'koyo/repl/version'

    def self.config
      @config ||= Configuration.new
    end

    def self.configure
      yield(config)
    end
  end
end
