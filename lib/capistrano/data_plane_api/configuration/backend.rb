# frozen_string_literal: true

require_relative 'symbol'
require_relative 'server'

module Capistrano
  module DataPlaneApi
    class Configuration < Type
      class Backend < Type
        attribute :name, ::Shale::Type::String
        attribute :styles, Symbol, collection: true
        attribute :basic_user, ::Shale::Type::String
        attribute :basic_password, ::Shale::Type::String
        attribute :servers, Server, collection: true
      end
    end
  end
end
