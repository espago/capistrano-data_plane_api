# typed: true
# frozen_string_literal: true

require_relative 'helper'

module Capistrano
  module DataPlaneApi
    module Deploy
      # Represents a collection of deployment stats for particular servers.
      class DeploymentStats
        # Configuration data of a particular HAProxy backend
        #
        #: Capistrano::DataPlaneApi::Configuration::Backend?
        attr_accessor :backend

        #: Time?
        attr_accessor :start_time

        #: Time?
        attr_accessor :end_time

        #: Hash[String, Deploy::ServerStats]
        attr_accessor :server_stats

        #: bool
        attr_accessor :success

        #: -> void
        def initialize
          @backend = nil
          @start_time = nil
          @end_time = nil
          @success = true
          @server_stats = {}
        end

        #: (String) -> Deploy::ServerStats
        def [](key)
          @server_stats[key]
        end

        #: (String, Deploy::ServerStats) -> void
        def []=(key, val)
          @server_stats[key] = val
        end

        #: (Array[Configuration::Server] | Configuration::Server) -> void
        def create_stats_for(servers)
          servers = *servers

          servers.each do |server|
            @server_stats[server.name] = ServerStats.new(server.name, T.must(@backend&.name))
          end
        end

        #: -> String
        def to_s
          update_states_in_stats

          time_string = COLORS.bold.yellow ::Time.now.to_s
          if success
            state = COLORS.bold.green 'Successful'
            time_sentence = 'took'
          else
            state = COLORS.bold.red 'Failed'
            time_sentence = 'failed after'
          end

          result = ::String.new
          result << "\n#{time_string}\n\n"
          result << "#{state} deployment to #{::Capistrano::DataPlaneApi.humanize_backend_name(T.must(@backend))}\n"
          result << "  #{time_sentence} #{Helper.humanize_time(T.must(seconds))}\n"

          @server_stats.each_value do |stats|
            result << "\n#{stats}"
          end

          result
        end

        # How much time has the deployment taken
        #: -> Integer?
        def seconds
          @seconds ||= Helper.seconds_since(T.must(@start_time), to: T.must(@end_time))
        end

        private

        #: -> void
        def update_states_in_stats
          return if @update_states_in_stats

          @update_states_in_stats = true
          update_states_in_stats!
        end

        #: -> void
        def update_states_in_stats!
          server_states = begin
            ::Capistrano::DataPlaneApi.get_backend_servers_settings(T.must(@backend&.name)).body
          rescue Error
            nil
          end

          return if server_states.nil?

          server_states.each do |server_state|
            @server_stats[server_state['name']]&.tap do |s|
              s.admin_state = server_state['admin_state']
              s.operational_state = server_state['operational_state']
            end
          end
        end

      end

    end
  end
end
