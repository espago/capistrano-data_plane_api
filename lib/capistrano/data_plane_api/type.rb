# typed: true
# frozen_string_literal: true

require 'shale'

require_relative 'diggable'
require_relative 'equatable'

module Capistrano
  module DataPlaneApi
    # A Base class for all types of the Data Plane API request and response bodies
    class Type < ::Shale::Mapper
      extend T::Helpers

      abstract!

      include Diggable
      include Equatable

      def to_h = to_hash

      #: (Symbol | String) -> Object?
      def [](key)
        public_send(key) if respond_to?(key)
      end

      #: (Symbol | String, Object) -> void
      def []=(key, val)
        public_send(:"#{key}=", val)
      end
    end
  end
end
