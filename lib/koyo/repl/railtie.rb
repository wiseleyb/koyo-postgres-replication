#require 'koyo_postgres_replication'
require 'rails'

module Koyo::Repl
  class Railtie < Rails::Railtie
    railtie_name :koyo_repl

    rake_tasks do
      namespace :koyo do
        namespace :repl do
          desc 'Diagnostics: Basic setup/state information'
          task diagnostics: :environment do
            puts ''
            puts '-' * 80
            puts 'Koyo::Repl::Diagnostic'
            puts Koyo::Repl::Diagnostics.new.rake_info.join("\n")
            puts '-' * 80
            puts ''
          end

          # Installs templates
          desc 'Install'
          task install: :environment do
            Koyo::Repl::Install.copy!
          end

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
