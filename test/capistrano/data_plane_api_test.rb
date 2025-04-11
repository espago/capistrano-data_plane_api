# typed: true
# frozen_string_literal: true

require 'test_helper'

class Capistrano::DataPlaneApiTest < ::TestCase
  def setup
    ::Capistrano::DataPlaneApi.configuration = {
      api_url:        'http://example.com',
      basic_user:     'user',
      basic_password: 'pass',
      backends:       [
        {
          name:    'foo_production',
          servers: [
            {
              name: 'foo_production_1',
            },
            {
              name: 'foo_production_2',
            },
          ],
        },
        {
          name:    'foo_staging',
          servers: [
            {
              name: 'foo_staging_1',
            },
          ],
        },
      ],
    }

    @api_config = ::DataPlaneApi::Configuration.new(
      basic_user:     ::Capistrano::DataPlaneApi.configuration.basic_user,
      basic_password: ::Capistrano::DataPlaneApi.configuration.basic_password,
      url:            ::Capistrano::DataPlaneApi.configuration.api_url,
    )
  end

  should 'have a version number' do
    refute_nil ::Capistrano::DataPlaneApi::VERSION
  end

  context 'server state' do

    should 'set to drain' do
      # initial `admin_state` of this server is `ready`
      # and this test should change this state to `drain`
      http_cassette do
        server, backend = ::Capistrano::DataPlaneApi.find_server_and_backend('foo_production_1')

        response =
          ::DataPlaneApi::Server.get_runtime_settings(
            backend: backend.name,
            name:    server.name,
            config:  @api_config,
          )

        assert_equal 'ready', response.body['admin_state']

        server_state = T.must ::Capistrano::DataPlaneApi.server_set_drain('foo_production_1')
        assert_equal 'drain', server_state['admin_state']

        response =
          ::DataPlaneApi::Server.get_runtime_settings(
            backend: backend.name,
            name:    server.name,
            config:  @api_config,
          )

        assert_equal 'drain', response.body['admin_state']
      end
    end

    should 'not set to drain when other servers are not up' do
      # initial `admin_state` of this server is `ready`
      #  the other foo_production server's operational_state is `down`
      http_cassette do
        server, backend = ::Capistrano::DataPlaneApi.find_server_and_backend('foo_production_1')

        response =
          ::DataPlaneApi::Server.get_runtime_settings(
            backend: backend.name,
            name:    server.name,
            config:  @api_config,
          )

        assert_equal 'ready', response.body['admin_state']

        assert_raises ::Capistrano::DataPlaneApi::NoOtherServerReadyError do
          ::Capistrano::DataPlaneApi.server_set_drain('foo_production_1')
        end

        response =
          ::DataPlaneApi::Server.get_runtime_settings(
            backend: backend.name,
            name:    server.name,
            config:  @api_config,
          )

        assert_equal 'ready', response.body['admin_state']
      end
    end

    should 'force to drain when other servers are not up' do
      # initial `admin_state` of this server is `ready`
      #  the other foo_production server's operational_state is `down`
      http_cassette do
        server, backend = ::Capistrano::DataPlaneApi.find_server_and_backend('foo_production_1')

        response =
          ::DataPlaneApi::Server.get_runtime_settings(
            backend: backend.name,
            name:    server.name,
            config:  @api_config,
          )

        assert_equal 'ready', response.body['admin_state']

        server_state = T.must ::Capistrano::DataPlaneApi.server_set_drain('foo_production_1', force: true)
        assert_equal 'drain', server_state['admin_state']

        response =
          ::DataPlaneApi::Server.get_runtime_settings(
            backend: backend.name,
            name:    server.name,
            config:  @api_config,
          )

        assert_equal 'drain', response.body['admin_state']
      end
    end

    should 'not set to drain when other servers are not ready' do
      # initial `admin_state` of this server is `ready`
      #  the other foo_production server is in `drain`
      http_cassette do
        server, backend = ::Capistrano::DataPlaneApi.find_server_and_backend('foo_production_1')

        response =
          ::DataPlaneApi::Server.get_runtime_settings(
            backend: backend.name,
            name:    server.name,
            config:  @api_config,
          )

        assert_equal 'ready', response.body['admin_state']

        assert_raises ::Capistrano::DataPlaneApi::NoOtherServerReadyError do
          ::Capistrano::DataPlaneApi.server_set_drain('foo_production_1')
        end

        response =
          ::DataPlaneApi::Server.get_runtime_settings(
            backend: backend.name,
            name:    server.name,
            config:  @api_config,
          )

        assert_equal 'ready', response.body['admin_state']
      end
    end

    should 'set to maint' do
      # initial `admin_state` of this server is `ready`
      # and this test should change this state to `maint`
      http_cassette do
        server, backend = ::Capistrano::DataPlaneApi.find_server_and_backend('foo_production_1')


        response =
          ::DataPlaneApi::Server.get_runtime_settings(
            backend: backend.name,
            name:    server.name,
            config:  @api_config,
          )

        assert_equal 'ready', response.body['admin_state']

        server_state = T.must ::Capistrano::DataPlaneApi.server_set_maint('foo_production_1')
        assert_equal 'maint', server_state['admin_state']

        response =
          ::DataPlaneApi::Server.get_runtime_settings(
            backend: backend.name,
            name:    server.name,
            config:  @api_config,
          )

        assert_equal 'maint', response.body['admin_state']
      end
    end

    should 'set to ready' do
      # initial `admin_state` of this server is `drain`
      # and this test should change this state to `ready`
      http_cassette do
        server, backend = ::Capistrano::DataPlaneApi.find_server_and_backend('foo_production_1')


        response =
          ::DataPlaneApi::Server.get_runtime_settings(
            backend: backend.name,
            name:    server.name,
            config:  @api_config,
          )

        assert_equal 'drain', response.body['admin_state']

        server_state = T.must ::Capistrano::DataPlaneApi.server_set_ready('foo_production_1')
        assert_equal 'ready', server_state['admin_state']

        response =
          ::DataPlaneApi::Server.get_runtime_settings(
            backend: backend.name,
            name:    server.name,
            config:  @api_config,
          )

        assert_equal 'ready', response.body['admin_state']
      end
    end

    should 'raise error when HAProxy responds with an error' do
      http_cassette do
        assert_raises ::Capistrano::DataPlaneApi::QueryError do
          ::Capistrano::DataPlaneApi.server_set_drain('foo_production_1')
        end

        assert_raises ::Capistrano::DataPlaneApi::UpdateServerStateError do
          ::Capistrano::DataPlaneApi.server_set_ready('foo_production_1')
        end
      end
    end

    should 'not drain when only one server is configured in a backend' do
      http_cassette do
        server, backend = ::Capistrano::DataPlaneApi.find_server_and_backend('foo_staging_1')

        response =
          ::DataPlaneApi::Server.get_runtime_settings(
            backend: backend.name,
            config:  @api_config,
          )

        # confirm that only one server is configured in this HAProxy backend
        assert_equal 1, response.body.length

        assert_equal 'ready', response.body.first['admin_state']

        assert !::Capistrano::DataPlaneApi.server_set_drain('foo_staging_1')

        response =
          ::DataPlaneApi::Server.get_runtime_settings(
            backend: backend.name,
            name:    server.name,
            config:  @api_config,
          )

        assert_equal 'ready', response.body['admin_state']
      end
    end

    should 'not ready when only one server is configured in a backend' do
      http_cassette do
        server, backend = ::Capistrano::DataPlaneApi.find_server_and_backend('foo_staging_1')

        response =
          ::DataPlaneApi::Server.get_runtime_settings(
            backend: backend.name,
            config:  @api_config,
          )

        # confirm that only one server is configured in this HAProxy backend
        assert_equal 1, response.body.length

        assert_equal 'drain', response.body.first['admin_state']

        assert !::Capistrano::DataPlaneApi.server_set_ready('foo_staging_1')

        response =
          ::DataPlaneApi::Server.get_runtime_settings(
            backend: backend.name,
            name:    server.name,
            config:  @api_config,
          )

        assert_equal 'drain', response.body['admin_state']
      end
    end
  end

  should 'raise error when a backend is not configured for a deployment stage' do
    assert_raises ::Capistrano::DataPlaneApi::NoBackendForThisStageError do
      ::Capistrano::DataPlaneApi.find_server_and_backend('dupa')
    end

    assert_raises ::Capistrano::DataPlaneApi::NoBackendForThisStageError do
      ::Capistrano::DataPlaneApi.server_set_ready('dupa')
    end

    assert_raises ::Capistrano::DataPlaneApi::NoBackendForThisStageError do
      ::Capistrano::DataPlaneApi.server_set_drain('dupa')
    end
  end

  should 'find backend when it exists' do
    backend = ::Capistrano::DataPlaneApi.find_backend('foo_staging')

    assert_equal 'foo_staging', backend.name
  end

  should 'not find backend when it does not exist' do
    assert_raises ::Capistrano::DataPlaneApi::NoSuchBackendError do
      ::Capistrano::DataPlaneApi.find_backend('back_dupa')
    end
  end
end
