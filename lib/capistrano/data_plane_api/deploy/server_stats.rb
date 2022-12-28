# frozen_string_literal: true

module Capistrano
  module DataPlaneApi
    module Deploy
      # Represents the stats of a deployment to a particular server
      class ServerStats
        # @return [Boolean, nil] `nil` when the deployment hasn't begun
        #   `true` when it has finished successfully, `false` when it has failed
        attr_accessor :success

        # @return [Time, nil]
        attr_accessor :start_time

        # @return [Time, nil]
        attr_accessor :end_time

        # @return [String]
        attr_accessor :server_name

        # @return [String]
        attr_accessor :backend_name

        # @return [String, nil]
        attr_accessor :admin_state

        # @return [String, nil]
        attr_accessor :operational_state

        # @param server_name [String]
        # @param backend_name [String]
        def initialize(server_name, backend_name)
          @server_name = server_name
          @backend_name = backend_name
          @success = nil
          @seconds = nil
        end

        # @return [String]
        def to_s
          time_string =
            case @success
            when nil    then 'skipped'
            when false  then "failed after #{Helper.humanize_time(seconds)}"
            when true   then "took #{Helper.humanize_time(seconds)}"
            end

          "  #{state_emoji} #{server_title} #{time_string}#{haproxy_states}"
        end

        # @return [Integer, nil] How much time has the deployment taken
        def seconds
          @seconds ||= Helper.seconds_since(@start_time, to: @end_time)
        end

        private

        # @return [String, nil]
        def humanize_admin_state
          ::Capistrano::DataPlaneApi.humanize_admin_state(@admin_state)
        end

        # @return [String, nil]
        def humanize_operational_state
          ::Capistrano::DataPlaneApi.humanize_operational_state(@operational_state)
        end

        # @return [String, nil]
        def haproxy_states
          <<-HAPROXY

                admin_state: #{humanize_admin_state}
          operational_state: #{humanize_operational_state}
          HAPROXY
        end

        # @return [Hash{String => Symbol}]
        SERVER_TITLE_COLORS = {
          nil => :yellow,
          false => :red,
          true => :green
        }.freeze
        private_constant :SERVER_TITLE_COLORS

        # @return [String]
        def server_title
          COLORS.decorate(server_id, :bold, SERVER_TITLE_COLORS[@success])
        end

        # @return [String]
        def server_id
          "#{@backend_name}:#{@server_name}"
        end

        # @return [Hash{Boolean, nil => Symbol}]
        STATE_EMOJIS = {
          nil => '🟡',
          false => '❌',
          true => '✅'
        }.freeze
        private_constant :STATE_EMOJIS

        # @return [String]
        def state_emoji
          STATE_EMOJIS[@success]
        end
      end
    end
  end
end
