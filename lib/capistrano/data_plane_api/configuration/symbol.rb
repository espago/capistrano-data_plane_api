# frozen_string_literal: true

module Capistrano
  module DataPlaneApi
    class Configuration < Type
      class Symbol < ::Shale::Type::String
        class << self
          def cast(value)
            value&.to_sym
          end
        end

      end
    end
  end
end
