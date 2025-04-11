# typed: true
# frozen_string_literal: true

require 'yaml'
require 'erb'
require 'logger'

require 'shale'

require_relative 'type'

::Dir[::File.expand_path('configuration/*.rb', __dir__)].each { require _1 }

module Capistrano
  module DataPlaneApi
    # Configuration object of the `capistrano-data_plane_api` gem.
    class Configuration < Type
      attribute :api_url, ::Shale::Type::String
      attribute :logger_level, ::Shale::Type::Integer, default: -> { ::Logger::DEBUG }
      attribute :backends, Backend, collection: true
      attribute :file_path, ::Shale::Type::String
      attribute :basic_user, ::Shale::Type::String
      attribute :basic_password, ::Shale::Type::String

      class << self
        #: (String) -> instance
        def from_file(path)
          from_yaml ::ERB.new(::File.read(path)).result
        end
      end
    end
  end
end
