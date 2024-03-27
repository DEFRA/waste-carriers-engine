# frozen_string_literal: true

module AddressFinderServiceStubHelper
  def stub_address_finder_service(options = {})
    ea_address_facade_v11_result = JSON.parse(file_fixture("ea_address_facade_v11_response.json").read)
    address_json = [ea_address_facade_v11_result.merge(options.stringify_keys)]

    response = instance_double(DefraRuby::Address::Response, results: address_json, successful?: true)

    allow(DefraRuby::Address::OsPlacesAddressLookupService).to receive(:run).and_return(response)
  end
end

RSpec.configure do |config|
  config.include AddressFinderServiceStubHelper
end
