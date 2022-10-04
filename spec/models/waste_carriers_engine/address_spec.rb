# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe Address, type: :model do
    describe "#assign_house_number_and_address_lines" do
      let(:address) { build(:address) }

      context "when it is given address data" do
        let(:data) do
          {
            "subBuildingName" => "FOO HOUSE",
            "buildingName" => "BAR BUILDINGS",
            "buildingNumber" => "42",
            "dependentThroughfare" => "BAZ STREET",
            "thoroughfareName" => "QUX CORNER",
            "dependentLocality" => "QUUX VILLAGE"
          }
        end

        context "when all the lines are used" do
          before do
            address.assign_house_number_and_address_lines(data)
          end

          it "assigns the correct house_number" do
            expect(address[:house_number]).to eq("FOO HOUSE, BAR BUILDINGS")
          end

          it "assigns the correct address_lines" do
            expect(address[:address_line_1]).to eq("42")
            expect(address[:address_line_2]).to eq("BAZ STREET")
            expect(address[:address_line_3]).to eq("QUX CORNER")
            expect(address[:address_line_4]).to eq("QUUX VILLAGE")
          end
        end

        context "when the lines are not all used" do
          before do
            data.merge!("subBuildingName" => nil, "buildingNumber" => nil, "dependentThroughfare" => nil)
            address.assign_house_number_and_address_lines(data)
          end

          it "assigns the correct house_number" do
            expect(address[:house_number]).to eq("BAR BUILDINGS")
          end

          it "skips blank fields when assigning lines" do
            expect(address[:address_line_1]).to eq("QUX CORNER")
            expect(address[:address_line_2]).to eq("QUUX VILLAGE")
            expect(address[:address_line_3].present?).to be false
            expect(address[:address_line_4].present?).to be false
          end
        end
      end
    end

    # NOTE: The OS Places API response payload spells dependentThoroughfare as dependentThroughfare.
    describe ".create_from_os_places_data" do
      let(:os_places_data) { JSON.parse(file_fixture("os_places_response.json").read) }

      subject(:address_from_os_places) { described_class.create_from_os_places_data(os_places_data) }

      shared_examples "skips blank field" do |blank_field, address_line, next_field|
        before { os_places_data[blank_field] = nil }

        it "skips to the next field" do
          expect(address_from_os_places[address_line]).to eq os_places_data[next_field]
        end
      end

      context "with all relevant fields except PO box number populated in the OS places response" do
        it "includes the correct values" do
          expect(address_from_os_places.attributes).to include(
            "uprn" => os_places_data["uprn"].to_i,
            "houseNumber" => "#{os_places_data['departmentName']}, #{os_places_data['organisationName']}",
            "addressLine1" => "#{os_places_data['subBuildingName']}, #{os_places_data['buildingName']}",
            "addressLine2" => "#{os_places_data['buildingNumber']}, #{os_places_data['dependentThroughfare']}",
            "addressLine3" => os_places_data["thoroughfareName"],
            "addressLine4" => os_places_data["dependentLocality"],
            "townCity" => os_places_data["town"],
            "postcode" => os_places_data["postcode"],
            "country" => os_places_data["country"],
            "dependentLocality" => os_places_data["dependentLocality"],
            "administrativeArea" => os_places_data["administrativeArea"],
            "localAuthorityUpdateDate" => os_places_data["localAuthorityUpdateDate"],
            "easting" => os_places_data["easting"].to_i,
            "northing" => os_places_data["northing"].to_i,
            "addressMode" => "address-results"
          )
        end

        # Overflow check: Confirm that an address created from a maximal OS payload has valid keys.
        it "does not have nil keys" do
          expect(address_from_os_places.attributes.keys).not_to include(nil)
        end

        context "with organisation details" do
          context "with an organisation name only" do
            before { os_places_data["departmentName"] = nil }

            it "uses the organisation name" do
              expect(address_from_os_places[:house_number]).to eq os_places_data["organisationName"]
            end
          end

          context "with a department name only" do
            before { os_places_data["organisationName"] = nil }

            it "uses the department name" do
              expect(address_from_os_places[:house_number]).to eq os_places_data["departmentName"]
            end
          end

          context "with both department name and organisation name" do
            it "comnbines department and organisation names" do
              expect(address_from_os_places[:house_number]).to eq "#{os_places_data['departmentName']}, #{os_places_data['organisationName']}"
            end
          end
        end

        context "with building details" do
          context "with a building name only" do
            before { os_places_data["subBuildingName"] = nil }

            it "uses the building name" do
              expect(address_from_os_places[:address_line_1]).to eq os_places_data["buildingName"]
            end
          end

          context "with a sub-building name only" do
            before { os_places_data["buildingName"] = nil }

            it "uses the sub-building name" do
              expect(address_from_os_places[:address_line_1]).to eq os_places_data["subBuildingName"]
            end
          end

          context "with both sub-building name and building name" do
            it "comnbines sub-building and building names" do
              expect(address_from_os_places[:address_line_1]).to eq "#{os_places_data['subBuildingName']}, #{os_places_data['buildingName']}"
            end
          end
        end

        context "with other optional fields not populated" do
          it_behaves_like "skips blank field", "buildingNumber",       :address_line_2, "dependentThroughfare"
          it_behaves_like "skips blank field", "dependentThroughfare", :address_line_3, "thoroughfareName"
          it_behaves_like "skips blank field", "thoroughfareName",     :address_line_4, "dependentLocality"
        end
      end

      context "with a PO box number" do
        let(:po_box_number) { "PO Box #{Faker::Number.number(digits: 4)}" }

        before do
          os_places_data["postOfficeBoxNumber"] = po_box_number
          os_places_data["subBuildingName"] = nil
          os_places_data["buildingName"] = nil
          os_places_data["buildingNumber"] = nil
        end

        it "includes the PO box number after the organisation details" do
          expect(address_from_os_places[:house_number]).to eq "#{os_places_data['departmentName']}, #{os_places_data['organisationName']}"
          expect(address_from_os_places[:address_line_1]).to eq po_box_number
        end

        it "includes the PO box number before the street details" do
          expect(address_from_os_places[:address_line_1]).to eq po_box_number
          expect(address_from_os_places[:address_line_2]).to eq os_places_data["dependentThroughfare"]
        end
      end
    end
  end
end
