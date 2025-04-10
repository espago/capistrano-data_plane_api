# typed: true
# frozen_string_literal: true

module Capistrano
  module DataPlaneApi
    class Configuration < Type
      # Contains the configuration options of a server
      class Server < Type
        attribute :name, ::Shale::Type::String
        attribute :stage, ::Shale::Type::String

        #: -> String?
        def stage
          @stage || @name
        end

        #: -> String?
        def name
          @name || @stage
        end
      end
    end
  end
end
