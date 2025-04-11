# typed: true
# frozen_string_literal: true

require 'test_helper'

class Capistrano::DataPlaneApi::Configuration < Capistrano::DataPlaneApi::Type
  class ServerTest < ::TestCase
    should 'return stage and name when both present' do
      serv = Server.new(stage: 'some_stage', name: 'some_name')
      assert_equal 'some_stage', serv.stage
      assert_equal 'some_name', serv.name
    end

    should 'return stage when name is not present' do
      serv = Server.new(stage: 'some_stage')
      assert_equal 'some_stage', serv.stage
      assert_equal 'some_stage', serv.name
    end

    should 'return name when stage is not present' do
      serv = Server.new(name: 'some_name')
      assert_equal 'some_name', serv.stage
      assert_equal 'some_name', serv.name
    end
  end
end
