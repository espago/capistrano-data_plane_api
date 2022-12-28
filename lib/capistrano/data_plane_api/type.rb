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
    end
  end
end
