# frozen_string_literal: true

require 'pastel'
require 'tty/box'
require 'data_plane_api'

module Capistrano
  module DataPlaneApi
    # Creates a human readable summary of the state of
    # HAProxy backends and servers to stdout.
    module ShowState
      class << self
        # @return [String]
        def call # rubocop:disable Metrics/MethodLength
          pastel = ::Pastel.new
          result = ::String.new

          result << pastel.blue.bold('HAProxy State')
          result << "\n"
          result << pastel.bold.yellow(::Time.now.to_s)
          result << "\n\n"
          config = ::DataPlaneApi::Configuration.new.tap do |c|
            c.logger = ::Logger.new($stdout)
            c.logger.level = ::Logger::FATAL
            c.timeout = 2
          end

          ::Capistrano::DataPlaneApi.configuration.backends.each do |backend|
            result << ::TTY::Box.frame(title: { top_left: backend_name(backend) }) do
              b = ::String.new
              servers = ::Capistrano::DataPlaneApi.get_backend_servers_settings(backend.name, config: config).body
              servers.each do |server|
                operational_state = operational_state(server)
                admin_state = admin_state(server)
                b << ::TTY::Box.frame(title:  { top_left: server_name(server) }, border: :thick) do
                  s = ::String.new
                  s << "      admin_state: #{admin_state}\n"
                  s << "operational_state: #{operational_state}\n"
                  s
                end
              end
              b

            rescue Error, ::Faraday::ConnectionFailed, ::Faraday::TimeoutError
              b << pastel.bold.bright_red('Unavailable!')
              b << "\n"
              b
            end
          end

          result
        end

        private

        # @param server [Hash{String => Object}]
        # @return [String]
        def operational_state(server)
          ::Capistrano::DataPlaneApi.humanize_operational_state(server['operational_state'])
        end

        # @param server [Hash{String => Object}]
        # @return [String]
        def admin_state(server)
          ::Capistrano::DataPlaneApi.humanize_admin_state(server['admin_state'])
        end

        # @param server [Hash{String => Object}]
        # @return [String]
        def server_name(server)
          pastel = ::Pastel.new
          pastel.bold server['name']
        end

        # @param backend [Capistrano::DataPlaneApi::Configuration::Backend]
        # @return [String]
        def backend_name(backend)
          pastel = ::Pastel.new
          pastel.decorate(" #{backend.name} ", *backend.styles)
        end

      end

    end
  end
end
