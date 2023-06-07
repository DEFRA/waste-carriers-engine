# frozen_string_literal: true

module WasteCarriersEngine
  class DiscernUkNumberTypeService < BaseService
    def run(phone_number:)
      # Remove any spaces in the phone number
      phone_number = phone_number.gsub(" ", "")

      # UK mobile numbers start with 07 or +447
      return "mobile" if phone_number =~ /^(07|\+447)/

      # UK landline numbers start with 01 or 02, or +441 or +442
      return "landline" if phone_number =~ /^(0[12]|\+441|\+442)/

      "unknown"
    end
  end
end
