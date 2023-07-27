#require 'koyo_postgres_replication'
require 'rails'

module Koyo::Repl
  class Railtie < Rails::Railtie
    railtie_name :koyo_repl

    rake_tasks do
      namespace :koyo do
        namespace :repl do
          # This can only be run once - no multiple servers
          desc 'Process replication slot events'
          task run_server: :environment do
            puts 'Running Koyo::Repl::PostgresServer.run!'
            Koyo::Repl::PostgresServer.run!
          end
        end
      end
    end
  end
end
