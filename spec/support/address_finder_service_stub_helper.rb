# frozen_string_literal: true

module AddressFinderServiceStubHelper
  def stub_address_finder_service(options = {})
    os_places_result = JSON.parse(file_fixture("os_places_response.json").read)
    address_json = [os_places_result.merge(options.stringify_keys)]

    response = double(:response, results: address_json, successful?: true)

    allow(DefraRuby::Address::OsPlacesAddressLookupService).to receive(:run).and_return(response)
  end
end

RSpec.configure do |config|
  config.include AddressFinderServiceStubHelper
end
