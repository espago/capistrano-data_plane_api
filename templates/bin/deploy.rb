#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../config/data_plane_api'
require 'capistrano/data_plane_api/deploy'

::Capistrano::DataPlaneApi::Deploy.call
