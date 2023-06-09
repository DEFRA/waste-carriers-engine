# frozen_string_literal: true

module WasteCarriersEngine
  class VerifyIfMobileService
    MOBILE_PREFIXES = %w[071 072 073 074 075 07624 077 078 079].freeze

    def self.run(phone_number:)
      return false unless phone_number

      # Strip out spaces and country codes, if present
      stripped_formatted_phone_number = phone_number.delete(" ").gsub(/^(\+44|0044|44)/, "0")

      MOBILE_PREFIXES.any? { |prefix| stripped_formatted_phone_number.start_with?(prefix) }
    end
  end
end
