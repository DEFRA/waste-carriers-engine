# frozen_string_literal: true

module Helpers
  module GraceWindows
    # We have various places in the tests where we adjust a date based on the
    # grace window. Since the valid grace window will change after a certain
    # date, this helper should ensure that tests pass before and after.
    def self.current_grace_window
      if 6.months.ago > Rails.configuration.end_of_covid_extension
        Rails.configuration.grace_window
      else
        Rails.configuration.covid_grace_window
      end
    end
  end
end
