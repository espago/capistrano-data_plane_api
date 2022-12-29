# frozen_string_literal: true

require 'rake'

namespace :data_plane_api do
  namespace :server do
    desc "Set the server's admin state to DRAIN through the HAProxy Data Plane API"
    task :set_drain do
      next if ::Capistrano::DataPlaneApi.no_haproxy?

      ::Capistrano::DataPlaneApi.server_set_drain fetch(:stage), force: ::Capistrano::DataPlaneApi.force_haproxy?
    end

    desc "Set the server's admin state to READY through the HAProxy Data Plane API"
    task :set_ready do
      next if ::Capistrano::DataPlaneApi.no_haproxy?

      sleep 3
      ::Capistrano::DataPlaneApi.server_set_ready fetch(:stage)
    end

    desc "Set the server's admin state to MAINT through the HAProxy Data Plane API"
    task :set_maint do
      next if ::Capistrano::DataPlaneApi.no_haproxy?

      sleep 3
      ::Capistrano::DataPlaneApi.server_set_maint fetch(:stage), force: true
    end
  end
end
