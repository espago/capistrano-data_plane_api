# frozen_string_literal: true

require 'data_plane_api'
require 'pastel'
require 'pathname'
require 'json'
require 'logger'

require_relative 'data_plane_api/version'
require_relative 'data_plane_api/helper'
require_relative 'data_plane_api/terminal_print_loop'
require_relative 'data_plane_api/configuration'
require_relative 'data_plane_api/show_state'

module Capistrano
  # Main module/namespace of the `capistrano-data_plane_api` gem.
  module DataPlaneApi
    extend Helper

    class Error < ::StandardError; end
    class NotConfiguredError < Error; end
    class QueryError < Error; end
    class NoOtherServerReadyError < Error; end
    class UpdateServerStateError < Error; end
    class NoSuchBackendError < Error; end
    class NoBackendForThisStageError < Error; end

    # @return [Pastel::Delegator]
    COLORS = ::Pastel.new

    class << self
      # @return [Capistrano::DataPlaneApi::Configuration]
      def configuration
        raise NotConfiguredError, <<~ERR unless @configuration
          `Capistrano::DataPlaneApi` is not configured!
          You should register a configuration file like so:
            Capistrano::DataPlaneApi.configuration = '/path/to/your/file.yaml'
        ERR

        @configuration
      end

      # @param val [Capistrano::DataPlaneApi::Configuration, Hash{String, Symbol => Object}, String, Pathname]
      def configuration=(val)
        case val
        when ::Hash
          # as of now `shale` does not support
          # symbol keys in hashes, so
          # we convert it to JSON an back
          # to a Hash to convert all Symbols
          # to Strings
          @configuration = Configuration.from_json(val.to_json)
        when Configuration
          @configuration = val
        when ::String, ::Pathname
          @configuration = Configuration.from_file(val.to_s)
          @configuration.file_path = val
        else
          raise ::ArgumentError,
                "Configuration should be a `#{::Hash}`, `#{Configuration}`, #{::String} or #{::Pathname}" \
                ", received: #{val.inspect} (#{val.class.inspect})"
        end
      end

      # Prints the current configuration in a human readable format.
      #
      # @return [void]
      def show_config
        puts ::JSON.pretty_generate(configuration.to_h)
      end

      # Prints the current state of all backends and
      # their servers in a human readable format.
      #
      # @return [void]
      def show_state
        TerminalPrintLoop.call do
          ShowState.call
        end
      end

      # Set server's admin_state to `drain`.
      #
      # @param deployment_stage [Symbol]
      # @param force [Boolean] Change the server's state even when no other server is `up`
      # @param config [::DataPlaneApi::Configuration, nil]
      # @return [Hash, FalseClass] Server state after the change, or `false`
      #   when no change happened
      # @raise [Error] The process failed due to some reason
      def server_set_drain(deployment_stage, force: false, config: nil)
        haproxy_server, haproxy_backend = find_server_and_backend(deployment_stage)
        return false if haproxy_backend.servers.length < 2 # skip HAProxy if there is only a single server

        validate_backend_state(haproxy_backend, haproxy_server) unless force

        conf = ::DataPlaneApi::Configuration.new(
          basic_user: haproxy_backend.basic_user || @configuration.basic_user,
          basic_password: haproxy_backend.basic_password || @configuration.basic_password,
          parent: config,
          url: configuration.api_url
        )

        # set the target server's state to `drain`
        response =
          ::DataPlaneApi::Server.update_transient_settings(
            backend: haproxy_backend.name,
            name: haproxy_server.name,
            settings: { admin_state: :drain },
            config: conf
          )

        unless response.status.between?(200, 299) && response.body['admin_state'] == 'drain'
          raise UpdateServerStateError,
                "HAProxy mutation failed! Couldn't set server's `admin_state` to `drain`."
        end

        response.body
      end

      # Set server's admin_state to `maint`.
      #
      # @param deployment_stage [Symbol]
      # @param force [Boolean] Change the server's state even when no other server is `up`
      # @param config [::DataPlaneApi::Configuration, nil]
      # @return [Hash, FalseClass] Server state after the change, or `false`
      #   when no change happened
      # @raise [Error] The process failed due to some reason
      def server_set_maint(deployment_stage, force: false, config: nil)
        haproxy_server, haproxy_backend = find_server_and_backend(deployment_stage)
        return false if haproxy_backend.servers.length < 2 # skip HAProxy if there is only a single server

        validate_backend_state(haproxy_backend, haproxy_server) unless force

        conf = ::DataPlaneApi::Configuration.new(
          basic_user: haproxy_backend.basic_user || @configuration.basic_user,
          basic_password: haproxy_backend.basic_password || @configuration.basic_password,
          parent: config,
          url: configuration.api_url
        )

        # set the target server's state to `maint`
        response =
          ::DataPlaneApi::Server.update_transient_settings(
            backend: haproxy_backend.name,
            name: haproxy_server.name,
            settings: { admin_state: :maint },
            config: conf
          )

        unless response.status.between?(200, 299) && response.body['admin_state'] == 'maint'
          raise UpdateServerStateError,
                "HAProxy mutation failed! Couldn't set server's `admin_state` to `drain`."
        end

        response.body
      end

      # Set server's admin_state to `ready`
      #
      # @param deployment_stage [Symbol]
      # @param config [::DataPlaneApi::Configuration, nil]
      # @return [Hash, FalseClass] Server state after the change, or `false`
      #   when no change happened
      # @raise [Error] The process failed due to some reason
      def server_set_ready(deployment_stage, config: nil)
        haproxy_server, haproxy_backend = find_server_and_backend(deployment_stage)
        return false if haproxy_backend.servers.length < 2 # skip HAProxy if there is only a single server

        conf = ::DataPlaneApi::Configuration.new(
          basic_user: haproxy_backend.basic_user || @configuration.basic_user,
          basic_password: haproxy_backend.basic_password || @configuration.basic_password,
          parent: config,
          url: configuration.api_url
        )

        # set the target server's state to `drain`
        response =
          ::DataPlaneApi::Server.update_transient_settings(
            backend: haproxy_backend.name,
            name: haproxy_server.name,
            settings: { admin_state: :ready },
            config: conf
          )

        unless response.status.between?(200, 299) &&
               response.body['admin_state'] == 'ready' &&
               response.body['operational_state'] == 'up'

          raise UpdateServerStateError,
                "HAProxy mutation failed! Couldn't set server's `admin_state` to `ready`."
        end

        response.body
      end

      # Find the HAProxy backend config with a particular name.
      #
      # @param backend_name [String]
      # @return [Capistrano::DataPlaneApi::Configuration::Backend] HAProxy backend config.
      # @raise [NoSuchBackendError] There is no backend with this name.
      def find_backend(backend_name)
        backend = configuration.backends.find { _1.name == backend_name }
        if backend.nil?
          raise NoSuchBackendError,
                'There is no HAProxy backend with this name! ' \
                "`#{backend_name.inspect}`"
        end

        backend
      end

      # Find the server and backend config for a particular
      # deployment stage.
      #
      # @param deployment_stage [Symbol, String]
      # @return [Capistrano::DataPlaneApi::Configuration::Server, Capistrano::DataPlaneApi::Configuration::Backend]
      #   Two-element Array
      #   where the first element is the HAProxy server config and the second one
      #   is the HAProxy backend config
      def find_server_and_backend(deployment_stage)
        # @type [Capistrano::DataPlaneApi::Configuration::Server, nil]
        haproxy_server = nil
        deployment_stage_str = deployment_stage.to_s
        # find the HAProxy backend that the
        # current deployment target is a part of
        # @type [Capistrano::DataPlaneApi::Configuration::Backend]
        haproxy_backend =
          configuration.backends.each do |backend|
            haproxy_server = backend.servers.find { _1.stage == deployment_stage_str }
            break backend if haproxy_server
          end

        unless haproxy_backend.is_a?(Configuration::Backend)
          raise NoBackendForThisStageError,
                'There are no HAProxy backends for this deployment stage! ' \
                "#{deployment_stage.inspect} `#{configuration.file_path.inspect}`"
        end

        [haproxy_server, haproxy_backend]
      end

      # @param backend_name [String]
      # @param config [::DataPlaneApi::Configuration, nil]
      # @return [Faraday::Response]
      def get_backend_servers_settings(backend_name, config: nil)
        haproxy_backend = find_backend(backend_name)
        conf = ::DataPlaneApi::Configuration.new(
          basic_user: haproxy_backend.basic_user || @configuration.basic_user,
          basic_password: haproxy_backend.basic_password || @configuration.basic_password,
          parent: config,
          url: configuration.api_url
        )
        response = ::DataPlaneApi::Server.get_runtime_settings(backend: backend_name, config: conf)
        unless response.status.between?(200, 299)
          raise QueryError,
                "HAProxy query failed! Couldn't fetch servers' states"
        end

        response
      end

      private

      # @param haproxy_backend [Capistrano::DataPlaneApi::Configuration::Backend]
      # @param haproxy_server [Capistrano::DataPlaneApi::Configuration::Server]
      # @return [void]
      def validate_backend_state(haproxy_backend, haproxy_server)
        response = get_backend_servers_settings(haproxy_backend.name)

        # @type [Array<Hash>]
        server_statuses = response.body
        # check if there are any servers other than this one that are `ready` and `up`
        other_servers_ready = server_statuses.any? do |server_status|
          server_status['admin_state'] == 'ready' &&
            server_status['operational_state'] == 'up' &&
            server_status['name'] != haproxy_server.name
        end

        unless other_servers_ready # rubocop:disable Style/GuardClause
          raise NoOtherServerReadyError,
                'No other server is `ready`' \
                "in this backend `#{haproxy_backend.name}`"
        end
      end

    end

  end
end

require_relative 'data_plane_api/tasks' if defined?(::Rake)
