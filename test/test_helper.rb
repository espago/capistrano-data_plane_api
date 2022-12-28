# frozen_string_literal: true

$LOAD_PATH.unshift ::File.expand_path('../lib', __dir__)
require 'capistrano/data_plane_api'

require 'minitest/autorun'
require 'shoulda-context'

require 'vcr'

::RELATIVE_CASSETTE_DIR = 'test/cassettes'

::VCR.configure do |c|
  c.default_cassette_options = { record: :once, serialize_with: :yaml }
  c.cassette_library_dir = ::RELATIVE_CASSETTE_DIR
  c.ignore_hosts 'localhost'
  c.allow_http_connections_when_no_cassette = true
  c.hook_into :webmock
end

::DataPlaneApi.configure do |c|
  c.logger.level = ::Logger::WARN
end

require_relative 'test_case'
