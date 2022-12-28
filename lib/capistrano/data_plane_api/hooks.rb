# frozen_string_literal: true

require_relative '../data_plane_api'

after 'deploy:started', 'data_plane_api:server:set_drain'
before 'deploy:publishing', 'data_plane_api:server:set_maint'
after 'deploy:finished', 'data_plane_api:server:set_ready'
