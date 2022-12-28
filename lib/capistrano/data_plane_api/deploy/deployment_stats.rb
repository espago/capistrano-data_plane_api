# frozen_string_literal: true

require_relative 'helper'

module Capistrano
  module DataPlaneApi
    module Deploy
      # Represents a collection of deployment stats for particular servers.
      class DeploymentStats
        # @return [Capistrano::DataPlaneApi::Configuration::Backend, nil]
        #   Configuration data of a particular HAProxy backend
        attr_accessor :backend

        # @return [Time, nil]
        attr_accessor :start_time

        # @return [Time, nil]
        attr_accessor :end_time

        # @return [Hash{String => Deploy::ServerStats}]
        attr_accessor :server_stats

        # @return [Boolean]
        attr_accessor :success

        def initialize
          @backend = nil
          @start_time = nil
          @end_time = nil
          @success = true
          @server_stats = {}
        end

        # @param key [String]
        # @return [Deploy::ServerStats]
        def [](key)
          @server_stats[key]
        end

        # @param key [String]
        # @param val [Deploy::ServerStats]
        def []=(key, val)
          @server_stats[key] = val
        end

        # @param servers [Array<Hash{String => Object}>, Hash{String => Object}]
        # @return [void]
        def create_stats_for(servers)
          servers = *servers

          servers.each do |server|
            @server_stats[server['name']] = ServerStats.new(server['name'], @backend.name)
          end
        end

        # @return [String]
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
          result << "#{state} deployment to #{::Capistrano::DataPlaneApi.humanize_backend_name(@backend)}\n"
          result << "  #{time_sentence} #{Helper.humanize_time(seconds)}\n"

          @server_stats.each_value do |stats|
            result << "\n#{stats}"
          end

          result
        end

        # @return [Integer, nil] How much time has the deployment taken
        def seconds
          @seconds ||= Helper.seconds_since(@start_time, to: @end_time)
        end

        private

        # @return [void]
        def update_states_in_stats
          return if @update_states_in_stats

          @update_states_in_stats = true
          update_states_in_stats!
        end

        def update_states_in_stats!
          server_states = begin
            ::Capistrano::DataPlaneApi.get_backend_servers_settings(@backend.name).body
          rescue Error
            nil
          end

          return unless server_states

          server_states.each do |server_state|
            @server_stats[server_state['name']]&.then do |s|
              s.admin_state = server_state['admin_state']
              s.operational_state = server_state['operational_state']
            end
          end
        end

      end

    end
  end
end
