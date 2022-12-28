# frozen_string_literal: true

require_relative '../data_plane_api'

module Capistrano
  module DataPlaneApi
    # Contains code used in the deployment script.
    module Deploy
      class << self
        # @return [void]
        def call
          args = Args.parse
          puts COLORS.bold.blue('Running the deployment script')

          result = Group.call(args)
          abort if result == false
        end
      end
    end
  end
end

require_relative 'deploy/args'
require_relative 'deploy/helper'
require_relative 'deploy/deployment_stats'
require_relative 'deploy/server_stats'
require_relative 'deploy/group'
