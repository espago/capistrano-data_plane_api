# frozen_string_literal: true

require 'optparse'

module Capistrano
  module DataPlaneApi
    module Deploy
      # Class which parses all provided command-line arguments
      # passed to the deployment script and saves them in
      # an object.
      class Args
        # @return [Array<String>]
        PRINTABLE_ENV_VARS = %w[BRANCH NO_MIGRATIONS].freeze

        # @param options [Array, nil]
        # @return [self]
        def self.parse(options = nil) # rubocop:disable Metrics/MethodLength, Style/ClassMethodsDefinitions
          args = new

          opt_parser = ::OptionParser.new do |parser| # rubocop:disable Metrics/BlockLength
            parser.banner = <<~BANNER
              Usage: bin/deploy [options]

              This script can be used to deploy this app to remote servers.

            BANNER

            parser.on(
              '-c',
              '--current',
              'Deploy from the currently checked out branch'
            ) do |_val|
              args.branch = `git branch --show-current`.strip
              ::ENV['BRANCH'] = args.branch
            end

            parser.on(
              '-t',
              '--test',
              'Show the commands that would be executed but do not carry out the deployment'
            ) do |val|
              args.test = val
            end

            parser.on(
              '-C',
              '--check',
              'Test deployment dependencies. ' \
              'Checks things like directory permissions, necessary utilities, ' \
              'HaProxy backends and servers'
            ) do |val|
              args.check = val
            end

            parser.on(
              '-g GROUP',
              '--group=GROUP',
              'Deploy the code to every server in the passed HAProxy backend/group'
            ) do |val|
              args.group = val
            end

            parser.on(
              '--no-haproxy',
              'Do not modify the state of any server in HAProxy'
            ) do |val|
              args.no_haproxy = val
              ::ENV['NO_HAPROXY'] = 'true'
            end

            parser.on(
              '--force-haproxy',
              'Ignore the current state of servers in HAProxy'
            ) do |val|
              args.force_haproxy = val
              ::ENV['FORCE_HAPROXY'] = 'true'
            end

            parser.on(
              '-o ONLY',
              '--only=ONLY',
              'Deploy the code only to the passed servers in the same order'
            ) do |val|
              next unless val

              args.only = val.split(',').map(&:strip).uniq
            end

            parser.on(
              '-H',
              '--haproxy-config',
              'Show the current HAProxy configuration'
            ) do |val|
              next unless val

              ::Signal.trap('INT') { exit }
              ::Capistrano::DataPlaneApi.show_config
              exit
            end

            parser.on(
              '-S',
              '--haproxy-state',
              'Show the current HAProxy state'
            ) do |val|
              next unless val

              ::Signal.trap('INT') { exit }
              ::Capistrano::DataPlaneApi.show_state
              exit
            end

            parser.on(
              '-T',
              '--tasks',
              'Print a list of all available deployment Rake tasks'
            ) do |val|
              next unless val

              puts COLORS.bold.blue('Available Rake Tasks')
              `cap -T`.each_line do |line|
                puts line.delete_prefix('cap ')
              end
              exit
            end

            parser.on(
              '-r RAKE',
              '--rake=RAKE',
              'Carry out a particular Rake task on the server'
            ) do |val|
              next unless val

              args.rake = val
            end

            parser.on('-h', '--help', 'Prints this help') do
              puts parser
              exit
            end

            parser.on(
              '-b BRANCH',
              '--branch=BRANCH',
              'Deploy the code from the passed Git branch'
            ) do |val|
              args.branch = val
              ::ENV['BRANCH'] = val
            end

            parser.on(
              '--no-migrations',
              'Do not carry out migrations'
            ) do |val|
              args.no_migrations = val
              ::ENV['NO_MIGRATIONS'] = 'true'
            end
          end

          opt_parser.parse!(options || ::ARGV)
          args.stage = ::ARGV.first&.start_with?('-') ? nil : ::ARGV.first
          args.prepare_if_one_server
          args
        end

        # @return [String, nil] Git branch that the code will be deployed to
        attr_accessor :branch
        # @return [Boolean] Runs in test mode if true, only prints commands without executing them
        attr_accessor :test
        # @return [String, nil] Name of the HAProxy server group/backend
        attr_accessor :group
        # @return [Boolean]
        attr_accessor :no_haproxy
        # @return [Boolean]
        attr_accessor :no_migrations
        # @return [Boolean]
        attr_accessor :force_haproxy
        # @return [Array<String>, nil] Ordered list of servers to which the app will be deployed
        attr_accessor :only
        # @return [String, nil] Rake command that will be called remotely (`deploy` by default)
        attr_accessor :rake
        # @return [String, nil] Name of the deployment stage/server
        attr_accessor :stage
        # @return [Boolean] Checks deployment dependencies
        attr_accessor :check

        alias test? test

        def initialize
          @rake = 'deploy'
        end

        # @return [Boolean]
        def only?
          return false if @only.nil?

          @only.any?
        end

        # @return [void]
        def prepare_if_one_server
          return unless one_server?

          server, backend = ::Capistrano::DataPlaneApi.find_server_and_backend(@stage)
          @only = [server['name']]
          @group = backend['name']
        end

        # @param stage [String, Symbol, nil]
        # @return [String]
        def deploy_command(stage = nil)
          used_stage = stage || self.stage
          "cap #{used_stage} #{rake}"
        end

        # @param stage [String, Symbol, nil]
        # @return [String]
        def humanized_deploy_command(stage = nil)
          result = ::String.new
          PRINTABLE_ENV_VARS.each do |env_var_name|
            next unless (value = ::ENV[env_var_name])

            result << "#{env_var_name}=#{value} "
          end

          result << deploy_command(stage)
          result
        end

        # @param key [Symbol, String]
        # @return [Object]
        def [](key)
          public_send(key)
        end

        # @param key [Symbol, String]
        # @param val [Object]
        # @return [Object]
        def []=(key, val)
          public_send("#{key}=", val)
        end

        private

        # @return [Boolean]
        def one_server?
          @stage && @group.nil?
        end
      end
    end

  end
end
