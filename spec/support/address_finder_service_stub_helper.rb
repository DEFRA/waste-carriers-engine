# frozen_string_literal: true

module AddressFinderServiceStubHelper
  # rubocop:disable Metrics/MethodLength
  def stub_address_finder_service(options)
    address_json = [{
      "moniker" => "340116",
      "uprn" => "340116",
      "lines" => ["NATURAL ENGLAND", "DEANERY ROAD"],
      "town" => "BRISTOL",
      "postcode" => "BS1 5AH",
      "easting" => "358205",
      "northing" => "172708",
      "country" => "",
      "dependentLocality" => "",
      "dependentThroughfare" => "",
      "administrativeArea" => "BRISTOL",
      "localAuthorityUpdateDate" => "",
      "royalMailUpdateDate" => "",
      "partial" => "NATURAL ENGLAND, HORIZON HOUSE, DEANERY ROAD, BRISTOL, BS1 5AH",
      "subBuildingName" => "",
      "buildingName" => "HORIZON HOUSE",
      "thoroughfareName" => "DEANERY ROAD",
      "organisationName" => "NATURAL ENGLAND",
      "buildingNumber" => "",
      "postOfficeBoxNumber" => "",
      "departmentName" => "",
      "doubleDependentLocality" => ""
    }.merge(options.stringify_keys)]

    allow_any_instance_of(::WasteCarriersEngine::AddressFinderService)
      .to receive(:search_by_postcode).and_return(address_json)
  end
  # rubocop:enable Metrics/MethodLength
end

RSpec.configure do |config|
  config.include AddressFinderServiceStubHelper
end
