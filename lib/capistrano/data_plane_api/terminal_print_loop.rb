# typed: true
# frozen_string_literal: true

require 'tty/cursor'

module Capistrano
  module DataPlaneApi
    # Provides a method that renders
    # strings in a terminal with the given interval.
    module TerminalPrintLoop
      class << self
        # Calls the passed block in an endless loop with a given interval
        # between calls.
        # It prints the `String` returned from the block and clears it
        # before another frame is printed.
        #
        # @param interval: Number of seconds between each screen refresh
        #: (Integer) { (String) -> Object } -> void
        def call(interval: 2, &_block)
          previous_line_count = 0
          previous_max_line_length = 0
          loop do
            content = ::String.new
            yielded = yield(content)

            print ::TTY::Cursor.clear_lines(previous_line_count + 1)

            content = yielded if yielded.is_a?(::String) && content.empty?
            line_count = 0
            max_line_length = 0
            content.each_line do |line|
              line_count += 1
              max_line_length = line.length if line.length > max_line_length
            end
            previous_line_count = line_count
            previous_max_line_length = max_line_length

            puts(content)
            sleep(interval)
          end
        end

      end
    end
  end
end
