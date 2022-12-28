# frozen_string_literal: true

module Capistrano
  module DataPlaneApi
    # Provides helper methods
    module Helper
      # @return [Hash{String => Symbol}]
      ADMIN_STATE_COLORS = {
        'drain' => :on_blue,
        'ready' => :on_green,
        'maint' => :on_yellow
      }.freeze

      # @return [Hash{String => Symbol}]
      OPERATIONAL_STATE_COLORS = {
        'up' => :on_green,
        'down' => :on_red,
        'stopping' => :on_yellow
      }.freeze

      # @return [Boolean]
      def no_haproxy?
        !::ENV['NO_HAPROXY'].nil? && !::ENV['NO_HAPROXY'].empty?
      end

      # @return [Boolean]
      def force_haproxy?
        !::ENV['FORCE_HAPROXY'].nil? && !::ENV['FORCE_HAPROXY'].empty?
      end

      # @param state [String, Symbol, nil]
      # @return [String, nil]
      def humanize_admin_state(state)
        return unless state

        state = state.to_s
        COLORS.decorate(" #{state.upcase} ", :bold, ADMIN_STATE_COLORS[state.downcase])
      end

      # @param state [String, Symbol, nil]
      # @return [String, nil]
      def humanize_operational_state(state)
        return unless state

        state = state.to_s
        COLORS.decorate(" #{state.upcase} ", :bold, OPERATIONAL_STATE_COLORS[state.downcase])
      end

      # @param backend [Capistrano::DataPlaneApi::Configuration::Backend]
      # @return [String]
      def humanize_backend_name(backend)
        COLORS.decorate(" #{backend.name} ", *backend.styles)
      end
    end
  end
end
