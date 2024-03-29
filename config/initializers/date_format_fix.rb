# frozen_string_literal: true

require "date"

class Date
  def to_s(format = :default)
    if (formatter = DATE_FORMATS[format])
      if formatter.respond_to?(:call)
        formatter.call(self).to_s
      else
        strftime(formatter)
      end
    else
      to_default_s
    end
  end
end
