# frozen_string_literal: true

module Capistrano
  module DataPlaneApi
    class Configuration < Type
      class Server < Type
        attribute :name, ::Shale::Type::String
        attribute :stage, ::Shale::Type::String

        # @return [String, nil]
        def stage
          @stage || @name
        end

        # @return [String, nil]
        def name
          @name || @stage
        end
      end
    end
  end
end
