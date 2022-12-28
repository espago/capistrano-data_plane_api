# frozen_string_literal: true

require 'capistrano/data_plane_api'

::Capistrano::DataPlaneApi.configuration =
  ::File.expand_path('data_plane_api.yml', __dir__)
