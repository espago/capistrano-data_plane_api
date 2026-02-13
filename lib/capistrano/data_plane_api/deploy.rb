# typed: true
# frozen_string_literal: true

require_relative '../data_plane_api'

module Capistrano
  module DataPlaneApi
    # Contains code used in the deployment script.
    module Deploy
      class << self
        # Returns when the deployment is over.
        # Aborts the program (exits with code 1) when the deployment has failed.
        #
        #: -> void
        def call
          result = call!
          abort if result == :failed
        end

        # Returns when the deployment is over.
        # Returns the final state of the deployment as a symbol `:failed`, `:pending` or `:success`
        #
        #: -> Symbol
        def call!
          args = Args.parse
          puts COLORS.bold.blue('Running the deployment script')

          Group.call(args)
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
