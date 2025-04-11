# typed: true

# DO NOT EDIT MANUALLY
# This is an autogenerated file for types exported from the `capistrano-data_plane_api` gem.
# Please instead update this file by running `spoom srb sigs export`.

module Capistrano; end

# Main module/namespace of the `capistrano-data_plane_api` gem.
module Capistrano::DataPlaneApi
  extend ::Capistrano::DataPlaneApi::Helper

  class << self
    # @raise [NotConfiguredError]
    sig { returns(::Capistrano::DataPlaneApi::Configuration) }
    def configuration; end

    sig do
      params(
        val: T.any(::Capistrano::DataPlaneApi::Configuration, ::Pathname, ::String, T::Hash[T.any(::String, ::Symbol), ::Object])
      ).void
    end
    def configuration=(val); end

    # Find the HAProxy backend config with a particular name.
    #
    # @return: HAProxy backend config.
    #
    # @raise [NoSuchBackendError] There is no backend with this name.
    sig { params(backend_name: T.any(::String, ::Symbol)).returns(::Capistrano::DataPlaneApi::Configuration::Backend) }
    def find_backend(backend_name); end

    # Find the server and backend config for a particular
    # deployment stage.
    #
    # @return:
    #   Two-element Array
    #   where the first element is the HAProxy server config and the second one
    #   is the HAProxy backend config
    sig do
      params(
        deployment_stage: T.any(::String, ::Symbol)
      ).returns([::Capistrano::DataPlaneApi::Configuration::Server, ::Capistrano::DataPlaneApi::Configuration::Backend])
    end
    def find_server_and_backend(deployment_stage); end

    sig do
      params(
        backend_name: T.any(::String, ::Symbol),
        config: T.nilable(::DataPlaneApi::Configuration)
      ).returns(::Faraday::Response)
    end
    def get_backend_servers_settings(backend_name, config: T.unsafe(nil)); end

    sig do
      params(
        backend_name: T.any(::String, ::Symbol),
        server_name: T.any(::String, ::Symbol),
        config: T.nilable(::DataPlaneApi::Configuration)
      ).returns(::Faraday::Response)
    end
    def get_server_settings(backend_name, server_name, config: T.unsafe(nil)); end

    # Get the state of the server.
    #
    # @return: Server state
    #
    # @raise [Error] The process failed due to some reason
    sig do
      params(
        deployment_stage: T.any(::String, ::Symbol),
        config: T.nilable(::DataPlaneApi::Configuration)
      ).returns(T.nilable(T::Hash[::String, T.untyped]))
    end
    def server_get_state(deployment_stage, config: T.unsafe(nil)); end

    # Set server's admin_state to `drain`.
    #
    # @return: Server state after the change, or `nil`
    #   when no change happened
    #
    # @raise [Error] The process failed due to some reason
    sig do
      params(
        deployment_stage: T.any(::String, ::Symbol),
        force: T::Boolean,
        config: T.nilable(::DataPlaneApi::Configuration)
      ).returns(T.nilable(T::Hash[::String, T.untyped]))
    end
    def server_set_drain(deployment_stage, force: T.unsafe(nil), config: T.unsafe(nil)); end

    # Set server's admin_state to `maint`.
    #
    # @return: Server state after the change, or `nil` when no change happened
    #
    # @raise [Error] The process failed due to some reason
    sig do
      params(
        deployment_stage: T.any(::String, ::Symbol),
        force: T::Boolean,
        config: T.nilable(::DataPlaneApi::Configuration)
      ).returns(T.nilable(T::Hash[::String, T.untyped]))
    end
    def server_set_maint(deployment_stage, force: T.unsafe(nil), config: T.unsafe(nil)); end

    # Set server's admin_state to `ready`
    #
    # @return: Server state after the change, or `nil` when no change happened
    #
    # @raise [Error] The process failed due to some reason
    sig do
      params(
        deployment_stage: T.any(::String, ::Symbol),
        config: T.nilable(::DataPlaneApi::Configuration)
      ).returns(T.nilable(T::Hash[::String, T.untyped]))
    end
    def server_set_ready(deployment_stage, config: T.unsafe(nil)); end

    # Prints the current configuration in a human readable format.
    sig { void }
    def show_config; end

    # Prints the current state of all backends and
    # their servers in a human readable format.
    sig { void }
    def show_state; end

    private

    sig do
      params(
        haproxy_backend: ::Capistrano::DataPlaneApi::Configuration::Backend,
        haproxy_server: ::Capistrano::DataPlaneApi::Configuration::Server
      ).void
    end
    def validate_backend_state(haproxy_backend, haproxy_server); end
  end
end

Capistrano::DataPlaneApi::COLORS = T.let(T.unsafe(nil), Pastel::Delegator)

# Configuration object of the `capistrano-data_plane_api` gem.
class Capistrano::DataPlaneApi::Configuration < ::Capistrano::DataPlaneApi::Type
  class << self
    sig { params(path: ::String).returns(T.attached_class) }
    def from_file(path); end
  end
end

# Contains the configuration options of a backend
class Capistrano::DataPlaneApi::Configuration::Backend < ::Capistrano::DataPlaneApi::Type; end

# Contains the configuration options of a server
class Capistrano::DataPlaneApi::Configuration::Server < ::Capistrano::DataPlaneApi::Type
  sig { returns(T.nilable(::String)) }
  def name; end

  sig { returns(T.nilable(::String)) }
  def stage; end
end

# A Shale type that represents a ruby `Symbol`
class Capistrano::DataPlaneApi::Configuration::Symbol < ::Shale::Type::String
  class << self
    def cast(value); end
  end
end

# Include in a class to grant it the `#dig` method.
# It's implemented so that it calls public methods.
module Capistrano::DataPlaneApi::Diggable
  include ::Booleans::KernelExtension
  include ::Kernel

  # Extracts the nested value specified by the sequence of key objects by calling `dig` at each step,
  # returning `nil` if any intermediate step is `nil`.
  #
  # This implementation of `dig` uses `public_send` under the hood.
  #
  # @raise [TypeError] value has no #dig method
  sig { params(args: T.untyped).returns(T.untyped) }
  def dig(*args); end
end

# Include in a class to make its instances capable
# of comparing themselves with other objects of the same class
# by calling `==` on their instance variables.
module Capistrano::DataPlaneApi::Equatable
  include ::Booleans::KernelExtension
  include ::Kernel

  # @param other [Object]
  # @return [Boolean]
  def ==(*args, **_arg1, &blk); end

  sig { params(other: ::Object).returns(T::Boolean) }
  def eql?(other); end
end

class Capistrano::DataPlaneApi::Error < ::StandardError; end

# Provides helper methods
module Capistrano::DataPlaneApi::Helper
  sig { returns(T::Boolean) }
  def force_haproxy?; end

  sig { params(state: T.nilable(T.any(::String, ::Symbol))).returns(T.nilable(::String)) }
  def humanize_admin_state(state); end

  sig { params(backend: ::Capistrano::DataPlaneApi::Configuration::Backend).returns(::String) }
  def humanize_backend_name(backend); end

  sig { params(state: T.nilable(T.any(::String, ::Symbol))).returns(T.nilable(::String)) }
  def humanize_operational_state(state); end

  sig { returns(T::Boolean) }
  def no_haproxy?; end
end

Capistrano::DataPlaneApi::Helper::ADMIN_STATE_COLORS = T.let(T.unsafe(nil), Hash)
Capistrano::DataPlaneApi::Helper::OPERATIONAL_STATE_COLORS = T.let(T.unsafe(nil), Hash)
class Capistrano::DataPlaneApi::NoBackendForThisStageError < ::Capistrano::DataPlaneApi::Error; end
class Capistrano::DataPlaneApi::NoOtherServerReadyError < ::Capistrano::DataPlaneApi::Error; end
class Capistrano::DataPlaneApi::NoSuchBackendError < ::Capistrano::DataPlaneApi::Error; end
class Capistrano::DataPlaneApi::NotConfiguredError < ::Capistrano::DataPlaneApi::Error; end
class Capistrano::DataPlaneApi::QueryError < ::Capistrano::DataPlaneApi::Error; end

# Creates a human readable summary of the state of
# HAProxy backends and servers to stdout.
module Capistrano::DataPlaneApi::ShowState
  class << self
    sig { returns(::String) }
    def call; end

    private

    sig { params(server: T::Hash[::String, T.untyped]).returns(T.nilable(::String)) }
    def admin_state(server); end

    sig { params(backend: ::Capistrano::DataPlaneApi::Configuration::Backend).returns(::String) }
    def backend_name(backend); end

    sig { params(server: T::Hash[::String, T.untyped]).returns(T.nilable(::String)) }
    def operational_state(server); end

    sig { params(server: T::Hash[::String, T.untyped]).returns(T.nilable(::String)) }
    def server_name(server); end
  end
end

# Provides a method that renders
# strings in a terminal with the given interval.
module Capistrano::DataPlaneApi::TerminalPrintLoop
  class << self
    # Calls the passed block in an endless loop with a given interval
    # between calls.
    # It prints the `String` returned from the block and clears it
    # before another frame is printed.
    sig { params(interval: ::Integer, _block: T.proc.params(arg0: ::String).returns(::Object)).void }
    def call(interval: T.unsafe(nil), &_block); end
  end
end

# A Base class for all types of the Data Plane API request and response bodies
#
# @abstract It cannot be directly instantiated. Subclasses must implement the `abstract` methods below.
class Capistrano::DataPlaneApi::Type < ::Shale::Mapper
  include ::Capistrano::DataPlaneApi::Diggable
  include ::Capistrano::DataPlaneApi::Equatable

  abstract!

  sig { params(key: T.any(::String, ::Symbol)).returns(T.nilable(::Object)) }
  def [](key); end

  sig { params(key: T.any(::String, ::Symbol), val: ::Object).void }
  def []=(key, val); end

  def to_h; end
end

class Capistrano::DataPlaneApi::UpdateServerStateError < ::Capistrano::DataPlaneApi::Error; end
Capistrano::DataPlaneApi::VERSION = T.let(T.unsafe(nil), String)
