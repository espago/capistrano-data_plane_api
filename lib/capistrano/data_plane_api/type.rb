# frozen_string_literal: true

require 'shale'

require_relative 'diggable'
require_relative 'equatable'

module Capistrano
  module DataPlaneApi
    class Type < ::Shale::Mapper
      include Diggable
      include Equatable

      alias to_h to_hash

      # @param key [Symbol, String]
      # @return [Object, nil]
      def [](key)
        public_send(key) if respond_to?(key)
      end

      # @param key [Symbol, String]
      # @param val [Object]
      def []=(key, val)
        public_send(:"#{key}=", val)
      end
    end
  end
end
