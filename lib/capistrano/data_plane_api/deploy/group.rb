# frozen_string_literal: true

module Capistrano
  module DataPlaneApi
    module Deploy
      # Class which deploys the app to all servers
      # in a particular HAProxy backend/group.
      class Group
        class << self
          # @param args [DeployArgs]
          # @return [void]
          def call(args)
            new(args).call
          end
        end

        # @param args [DeployArgs]
        def initialize(args)
          @args = args
          @deployment_stats = DeploymentStats.new
        end

        # @return [Boolean, nil] Whether the deployment has been successful
        def call
          @backend = ::Capistrano::DataPlaneApi.find_backend(@args.group)
          @servers = servers(@backend)
          start_deployment

          success = nil
          @servers.each do |server|
            server_stats = @deployment_stats[server.name]
            puts COLORS.bold.blue("Deploying the app to `#{server.stage}` -- `#{@backend.name}:#{server.name}`")

            puts @args.humanized_deploy_command(server.stage)
            puts

            next if @args.test?

            server_stats.start_time = ::Time.now
            deploy_command = @args.deploy_command(server.stage)
            success = system deploy_command

            server_stats.end_time = ::Time.now
            server_stats.success = success

            next if success

            puts COLORS.bold.red("Command `#{deploy_command}` failed")
            break
          end

          return if @args.test?

          finish_deployment(success: success)
          print_summary
          success
        end

        private

        # @return [void]
        def start_deployment
          @deployment_stats.tap do |d|
            d.start_time = ::Time.now
            d.backend = @backend
            d.create_stats_for @servers
          end
        end

        # @param success [Boolean]
        def finish_deployment(success: true)
          @deployment_stats.end_time = ::Time.now
          @deployment_stats.success = success
        end

        # @return [void]
        def print_summary
          puts @deployment_stats
        end

        # @param backend [Capistrano::DataPlaneApi::Configuration::Backend]
        # @return [Array<Capistrano::DataPlaneApi::Configuration::Server>]
        def servers(backend)
          return backend.servers unless @args.only?

          chosen_servers = []
          @args.only.each do |current_server_name|
            backend.servers.each do |server|
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
