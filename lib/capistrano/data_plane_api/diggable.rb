# typed: true
# frozen_string_literal: true

module Capistrano
  module DataPlaneApi
    # Include in a class to grant it the `#dig` method.
    # It's implemented so that it calls public methods.
    module Diggable
      include Kernel

      # Extracts the nested value specified by the sequence of key objects by calling `dig` at each step,
      # returning `nil` if any intermediate step is `nil`.
      #
      # This implementation of `dig` uses `public_send` under the hood.
      #
      # @raise [TypeError] value has no #dig method
      #: (*untyped) -> untyped
      def dig(*args)
        return unless args.size.positive?

        return unless respond_to?(key = args.shift)

        value = public_send(key)
        return if value.nil?
        return value if args.empty?
        raise ::TypeError, "#{value.class} does not have #dig method" unless value.respond_to?(:dig)

        value.dig(*args)
      rescue ::ArgumentError
        nil
      end
    end
  end
end
