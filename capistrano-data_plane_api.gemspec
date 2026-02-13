# frozen_string_literal: true

require_relative 'lib/capistrano/data_plane_api/version'

::Gem::Specification.new do |spec|
  spec.name = 'capistrano-data_plane_api'
  spec.version = ::Capistrano::DataPlaneApi::VERSION
  spec.authors = ['Mateusz Drewniak', 'Espago']
  spec.email = ['m.drewniak@espago.com']

  spec.summary = 'Capistrano plugin which helps you automatically change the admin state of your HAProxy servers'
  spec.description = 'Capistrano plugin which helps you automatically change the admin state of your HAProxy servers'
  spec.homepage = 'https://github.com/espago/capistrano-data_plane_api'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.2.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/espago/capistrano-data_plane_api'
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = ::Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|circleci)|appveyor)})
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| ::File.basename(f) }
  spec.require_paths = ['lib']

  # Uncomment to register a new dependency of your gem
  spec.add_dependency 'booleans', '~> 0.1'
  spec.add_dependency 'data_plane_api', '>= 0.2'
  spec.add_dependency 'pastel', '< 1'
  spec.add_dependency 'shale', '>= 1', '< 2'
  spec.add_dependency 'shale-builder', '>= 0.2.4', '<= 0.8.5'
  spec.add_dependency 'sorbet-runtime', '~> 0.5'
  spec.add_dependency 'thor', '> 1', '< 2'
  spec.add_dependency 'tty-box', '< 1'
  spec.add_dependency 'tty-cursor', '< 1'

  spec.metadata['rubygems_mfa_required'] = 'true'
end
