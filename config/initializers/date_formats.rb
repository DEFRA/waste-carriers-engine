# frozen_string_literal: true

Date::DATE_FORMATS[:default] = "%e %B %Y"
Time::DATE_FORMATS[:entity_matching] = "%d-%m-%Y"
Time::DATE_FORMATS[:day_month_year] = "%d %B %Y"
# For example: 6:53pm on 2 December 2019
Time::DATE_FORMATS[:time_on_day_month_year] = "%l:%M%P on %e %B %Y"
# For example: December 2019
Time::DATE_FORMATS[:month_year] = "%B %Y"
