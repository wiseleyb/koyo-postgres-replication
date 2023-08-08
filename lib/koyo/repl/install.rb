# frozen_string_literal: true

module Koyo
  module Repl
    # Provides state and debugging info for Repl setup
    # can be run with rake koyo::repl::diagnostics
    class Install
      def self.copy!
        kri = Koyo::Repl::Install.new
        kri.copy!
        kri.drop_create_slot!
      end

      def copy!
        puts ''
        puts '-' * 80
        copy("#{template_path}/koyo_postgres_replication_config.txt",
             "#{rails_path}/config/initializers/"\
               'koyo_postgres_replication_config.rb')

        copy("#{template_path}/koyo_repl_handler_service.txt",
             "#{rails_path}/app/models/koyo_repl_handler_service.rb")

        copy("#{template_path}/koyo_repl_model_example.txt",
             "#{rails_path}/app/models/koyo_repl_model_example.rb")
        puts '-' * 80
      end

      def drop_create_slot!
        Koyo::Repl::Database.delete_replication_slot!
        Koyo::Repl::Database.create_replication_slot!
      end

      def file_exists?(fname)
        if File.exist?(fname)
          puts "SKIPPING: #{fname} exists. Delete this file to recreated it."
          return true
        end
        false
      end

      def copy(from_fname, to_fname)
        return if file_exists?(to_fname)

        puts "ADDING #{to_fname}"
        dir_name = File.dirname(to_fname)
        FileUtils.mkdir_p(dir_name)
        FileUtils.cp(from_fname, to_fname.gsub('.txt', '.rb'))
      end

      def template_path
        "#{File.dirname(__FILE__)}/templates"
      end

      def rails_path
        Rails.root.to_s
      end
    end
  end
end
