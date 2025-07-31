# frozen_string_literal: true

require "rest-client"

module WasteCarriersEngine
  class AddressLookupService < BaseService
    def run(postcode)
      DefraRuby::Address::EaAddressFacadeV11Service.run(postcode)
    end
  end
end
