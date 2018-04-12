FactoryBot.define do
  factory :contact_address_form do
    trait :has_required_data do
      temp_address "340116"
      temp_addresses [{
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
      }]

      addresses { [build(:address, :has_required_data, :contact)] }

      initialize_with { new(create(:transient_registration, :has_required_data, workflow_state: "contact_address_form")) }
    end
  end
end
