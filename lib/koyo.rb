# frozen_string_literal: true

module Koyo
  module Repl
    require_relative 'koyo/repl/configuration'
    require_relative 'koyo/repl/data'
    require_relative 'koyo/repl/data_row'
    require_relative 'koyo/repl/log'
    require_relative 'koyo/repl/mod'
    require_relative 'koyo/repl/postgres_server'
    require_relative 'koyo/repl/utils'
    require_relative 'koyo/repl/version'

    require_relative 'koyo/repl/railtie' #if defined?(Rails)

    def self.config
      @configuration ||= Configuration.new
    end

    def self.configure(&block)
      yield(config)
    end
  end
end