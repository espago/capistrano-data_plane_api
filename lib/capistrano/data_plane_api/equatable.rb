# typed: true
# frozen_string_literal: true

module Capistrano
  module DataPlaneApi
    # Include in a class to make its instances capable
    # of comparing themselves with other objects of the same class
    # by calling `==` on their instance variables.
    module Equatable
      include Kernel

      #: (Object) -> bool
      def eql?(other)
        return true if equal?(other)
        return false unless other.is_a?(self.class) || is_a?(other.class)

        # @type [Set<Symbol>]
        self_ivars = instance_variables.to_set
        # @type [Set<Symbol>]
        other_ivars = other.instance_variables.to_set

        return false unless self_ivars == other_ivars

        self_ivars.each do |ivar|
          return false if instance_variable_get(ivar) != other.instance_variable_get(ivar)
        end

        true
      end

      alias == eql?
    end
  end
end
