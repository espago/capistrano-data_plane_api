# frozen_string_literal: true

require 'rake'
require 'capistrano/data_plane_api/deploy'

namespace :data_plane_api do # rubocop:disable Metrics/BlockLength
  namespace :server do # rubocop:disable Metrics/BlockLength
    desc "Set the server's admin state to DRAIN through the HAProxy Data Plane API"
    task :set_drain do
      on roles :web do
        next if ::Capistrano::DataPlaneApi.no_haproxy?

        ::Capistrano::DataPlaneApi.server_set_drain fetch(:stage), force: ::Capistrano::DataPlaneApi.force_haproxy?
      end
    end

    desc "Set the server's admin state to READY through the HAProxy Data Plane API"
    task :set_ready do
      on roles :web do
        next if ::Capistrano::DataPlaneApi.no_haproxy?

        sleep 3
        ::Capistrano::DataPlaneApi.server_set_ready fetch(:stage)
      end
    end

    desc "Set the server's admin state to MAINT through the HAProxy Data Plane API"
    task :set_maint do
      on roles :web do
        next if ::Capistrano::DataPlaneApi.no_haproxy?

        sleep 3
        ::Capistrano::DataPlaneApi.server_set_maint fetch(:stage), force: true
      end
    end

    desc 'Check the state of the HaProxy server'
    task :check do
      on roles :web do
        next if ::Capistrano::DataPlaneApi.no_haproxy?

        c = ::Capistrano::DataPlaneApi::COLORS
        server, backend = ::Capistrano::DataPlaneApi.find_server_and_backend(fetch(:stage))

        state = ::Capistrano::DataPlaneApi.server_get_state(fetch(:stage))

        stats = ::Capistrano::DataPlaneApi::Deploy::ServerStats.new(
          server.name,
          backend.name,
          state:             :info,
          admin_state:       state['admin_state'],
          operational_state: state['operational_state'],
        )

        human_name = c.decorate(" #{backend.name}:#{server.name} ", *backend.styles)
        puts "\nUpdates HaProxy state for #{human_name}\n#{stats}\n\n"
      end
    end
  end
end
