# frozen_string_literal: true

require_relative 'lib/koyo'

Gem::Specification.new do |spec|
  spec.name = 'koyo_postgres_replication'
  spec.version = Koyo::Repl::VERSION
  spec.authors = ['Ben Wiseley']
  spec.email = ['wiseleyb@gmail.com']

  spec.summary = 'Simple replication handler for Postgres'
  spec.description = 'Implements simple solution to hand off postgres '\
                     'replication events to local code.'
  spec.homepage = 'https://github.com/wiseleyb/koyo_postgres_replication'
  spec.required_ruby_version = '>= 2.6.0'

  #spec.metadata['allowed_push_host'] = "Set to your gem server 'https://example.com'"

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/wiseleyb/koyo_postgres_replication'
  spec.metadata['changelog_uri'] = 'https://github.com/wiseleyb/koyo_postgres_replication'

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == 
       __FILE__) || 
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor])
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency "rails"
  spec.add_dependency "rake"
end
