#!/usr/bin/env ruby

require_relative '../config/data_plane_api'

::Capistrano::DataPlaneApi::Deploy.call
