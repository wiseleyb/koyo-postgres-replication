# frozen_string_literal: true

require 'rails'

module Koyo
  module Repl
    # Adds rake tasks accessible to Rails project
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

            desc 'Install templates unless they already exist'
            task install: :environment do
              Koyo::Repl::Install.copy!
            end

            desc 'Process replication slot events - only run this server ONCE'
            task run_server: :environment do
              puts 'Running Koyo::Repl::PostgresServer.run!'
              Koyo::Repl::PostgresServer.run!
            end

            desc 'Recreate replication slot'
            task recreate: :environment do
              Koyo::Repl::Database.drop_create_slot!
            end
          end
        end
      end
    end
  end
end
