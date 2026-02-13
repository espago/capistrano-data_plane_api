# typed: true
# frozen_string_literal: true

module Capistrano
  module DataPlaneApi
    # Provides helper methods
    module Helper
      ADMIN_STATE_COLORS = {
        'unknown' => :on_red,
        'drain'   => :on_blue,
        'ready'   => :on_green,
        'maint'   => :on_yellow,
      }.freeze #: Hash[String, Symbol]

      OPERATIONAL_STATE_COLORS = {
        'unknown'  => :on_red,
        'up'       => :on_green,
        'down'     => :on_red,
        'stopping' => :on_yellow,
      }.freeze #: Hash[String, Symbol]

      #: -> bool
      def no_haproxy?
        no_haproxy = ::ENV['NO_HAPROXY']
        !no_haproxy.nil? && !no_haproxy.empty?
      end

      #: -> bool
      def force_haproxy?
        force_haproxy = ::ENV['FORCE_HAPROXY']
        !force_haproxy.nil? && !force_haproxy.empty?
      end

      #: (String | Symbol | nil) -> String?
      def humanize_admin_state(state)
        return unless state

        state = state.to_s
        COLORS.decorate(" #{state.upcase} ", :bold, ADMIN_STATE_COLORS[state.downcase])
      end

      #: (String | Symbol | nil) -> String?
      def humanize_operational_state(state)
        return unless state

        state = state.to_s
        COLORS.decorate(" #{state.upcase} ", :bold, OPERATIONAL_STATE_COLORS[state.downcase])
      end

      #: (Configuration::Backend) -> String
      def humanize_backend_name(backend)
        T.unsafe(COLORS).decorate(" #{backend.name} ", *backend.styles) # rubocop:disable Sorbet/ForbidTUnsafe
      end
    end
  end
end
