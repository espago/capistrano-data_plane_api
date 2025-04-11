# typed: strict
# frozen_string_literal: true

module Capistrano
  module DataPlaneApi
    module Deploy
      # Represents the stats of a deployment to a particular server
      class ServerStats
        # `nil` when the deployment hasn't begun
        #  `true` when it has finished successfully, `false` when it has failed
        #
        #: Symbol
        attr_accessor :state

        #: Time?
        attr_accessor :start_time

        #: Time?
        attr_accessor :end_time

        #: String
        attr_accessor :server_name

        #: String
        attr_accessor :backend_name

        #: String
        attr_accessor :admin_state

        #: String
        attr_accessor :operational_state

        #: (String, String, Symbol, String, String) -> void
        def initialize(
          server_name,
          backend_name,
          state: :pending,
          admin_state: 'unknown',
          operational_state: 'unknown'
        )
          @server_name = server_name
          @backend_name = backend_name
          @state = state
          @admin_state = admin_state
          @operational_state = operational_state
          @seconds = T.let(nil, T.nilable(Integer))
        end

        #: -> String
        def to_s
          time_string =
            case @state
            when :pending then 'skipped'
            when :failed  then "failed after #{Helper.humanize_time(T.must(seconds))}"
            when :success then "took #{Helper.humanize_time(T.must(seconds))}"
            when :info    then "at #{Time.now}"
            end

          "  #{state_emoji} #{server_title} #{time_string}#{haproxy_states}"
        end

        # How much time has the deployment taken
        #
        #: -> Integer?
        def seconds
          @seconds ||= Helper.seconds_since(T.must(@start_time), to: T.must(@end_time))
        end

        private

        #: -> String?
        def humanize_admin_state
          ::Capistrano::DataPlaneApi.humanize_admin_state(@admin_state)
        end

        #: -> String?
        def humanize_operational_state
          ::Capistrano::DataPlaneApi.humanize_operational_state(@operational_state)
        end

        #: -> String?
        def haproxy_states
          <<-HAPROXY

                admin_state: #{humanize_admin_state}
          operational_state: #{humanize_operational_state}
          HAPROXY
        end

        SERVER_TITLE_COLORS = T.let(
          {
            pending: :yellow,
            failed:  :red,
            success: :green,
            info:    :blue,
          }.freeze,
          T::Hash[Symbol, Symbol],
        )
        private_constant :SERVER_TITLE_COLORS

        #: -> String
        def server_title
          COLORS.decorate(server_id, :bold, SERVER_TITLE_COLORS.fetch(@state))
        end

        #: -> String
        def server_id
          "#{@backend_name}:#{@server_name}"
        end

        STATE_EMOJIS = T.let(
          {
            pending: '🟡',
            failed:  '❌',
            success: '✅',
            info:    'ℹ️',
          }.freeze,
          T::Hash[Symbol, String],
        )
        private_constant :STATE_EMOJIS

        #: -> String
        def state_emoji
          STATE_EMOJIS.fetch(@state)
        end
      end
    end
  end
end
