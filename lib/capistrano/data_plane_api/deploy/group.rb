# typed: strict
# frozen_string_literal: true

module Capistrano
  module DataPlaneApi
    module Deploy
      # Class which deploys the app to all servers
      # in a particular HAProxy backend/group.
      class Group
        class << self
          #: (Args) -> Symbol
          def call(args)
            new(args).call
          end
        end

        #: (Args) -> void
        def initialize(args)
          @args = args
          @deployment_stats = T.let(DeploymentStats.new, DeploymentStats)
          @backend = T.let(nil, T.nilable(Configuration::Backend))
          @servers = T.let(nil, T.nilable(T::Array[Configuration::Server]))
        end

        # Whether the deployment has been successful
        #: -> Symbol
        def call
          @backend = ::Capistrano::DataPlaneApi.find_backend(T.must(@args.group))
          @servers = servers(@backend)
          start_deployment

          state = :pending
          @servers&.each do |server|
            server_stats = @deployment_stats[T.must(server.name)]
            puts COLORS.bold.blue("Deploying the app to `#{server.stage}` -- `#{@backend.name}:#{server.name}`")

            puts @args.humanized_deploy_command(server.stage)
            puts

            next if @args.test?

            server_stats.start_time = ::Time.now
            deploy_command = @args.deploy_command(server.stage)
            case system deploy_command
            when true
              state = :success
            when false
              state = :failed
            when nil
              state = :pending
            end

            server_stats.end_time = ::Time.now
            server_stats.state = state

            next if state == :success

            puts COLORS.bold.red("Command `#{deploy_command}` failed")
            break
          end

          return :pending if @args.test?

          finish_deployment(state: state)
          print_summary
          state
        end

        private

        #: -> void
        def start_deployment
          @deployment_stats.tap do |d|
            d.start_time = ::Time.now
            d.backend = @backend
            d.create_stats_for @servers
          end
        end

        #: (Symbol) -> void
        def finish_deployment(state: :success)
          @deployment_stats.end_time = ::Time.now
          @deployment_stats.state = state
        end

        #: -> void
        def print_summary
          puts @deployment_stats
        end

        #: (Configuration::Backend) -> Array[Configuration::Server]?
        def servers(backend)
          return backend.servers unless @args.only?

          chosen_servers = []
          @args.only&.each do |current_server_name|
            backend.servers&.each do |server|
              next unless server.name == current_server_name || server.stage == current_server_name

              chosen_servers << server
            end
          end

          chosen_servers
        end
      end
    end
  end
end
