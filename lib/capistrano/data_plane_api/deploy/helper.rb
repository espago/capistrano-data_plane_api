# typed: true
# frozen_string_literal: true

module Capistrano
  module DataPlaneApi
    module Deploy
      # A module which provides some generic helper methods used
      # in the deployment script.
      module Helper
        extend self

        #: (Integer) -> String
        def humanize_time(seconds)
          hours = seconds / 3600
          rest_seconds = seconds - (hours * 3600)
          minutes = rest_seconds / 60
          rest_seconds = seconds - (minutes * 60)

          result = ::String.new

          if rest_seconds.positive?
            result.prepend "#{rest_seconds}s"
            styles = %i[bright_green]
          end

          if minutes.positive?
            result.prepend "#{minutes}min "
            styles = %i[bright_yellow]
          end

          if hours.positive?
            result.prepend "#{hours}h "
            styles = %i[bright_red]
          end

          COLORS.decorate(result.strip, *styles)
        end

        # Calculate how many seconds have passed
        # since the given point in time.
        #
        #: (Time, Time) -> Integer
        def seconds_since(time, to: ::Time.now)
          (to - time).to_i
        end
      end
    end
  end
end
