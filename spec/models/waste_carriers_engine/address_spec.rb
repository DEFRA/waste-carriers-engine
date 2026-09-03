# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe Address do
    describe "#assign_house_number_and_address_lines" do
      let(:address) { build(:address) }

      context "when it is given address data" do
        let(:data) do
          {
            "organisation" => "ACME CORP",
            "premises" => "HORIZON HOUSE",
            "street_address" => "DEANERY ROAD",
            "locality" => "SOUTH BRISTOL"
          }
        end

        context "when all the lines are used" do
          before do
            address.assign_house_number_and_address_lines(data)
          end

          it "assigns the correct house_number" do
            expect(address[:house_number]).to eq("ACME CORP")
          end

          it "assigns the correct address_lines" do
            expect(address[:address_line_1]).to eq("HORIZON HOUSE")
            expect(address[:address_line_2]).to eq("DEANERY ROAD")
            expect(address[:address_line_3]).to eq("SOUTH BRISTOL")
            expect(address[:address_line_4]).to be_nil
          end
        end

        context "when the lines are not all used" do
          before do
            data.merge!("organisation" => nil, "locality" => nil)
            address.assign_house_number_and_address_lines(data)
          end

          it "assigns the correct house_number" do
            expect(address[:house_number]).to eq("HORIZON HOUSE")
          end

          it "skips blank fields when assigning lines" do
            expect(address[:address_line_1]).to eq("DEANERY ROAD")
            expect(address[:address_line_2]).to be_nil
            expect(address[:address_line_3]).to be_nil
            expect(address[:address_line_4]).to be_nil
          end
        end
      end

      context "when extracting house number from address field" do
        context "with a residential address (org and premises are nil)" do
          let(:data) do
            {
              "address" => "10 HIGH STREET, LONDON, SW1A 1AA",
              "organisation" => nil,
              "premises" => nil,
              "street_address" => "HIGH STREET",
              "locality" => "LONDON"
            }
          end

          before { address.assign_house_number_and_address_lines(data) }

          it "extracts the house number from the address field" do
            expect(address[:house_number]).to eq("10")
          end

          it "assigns the street_address to address_line_1" do
            expect(address[:address_line_1]).to eq("HIGH STREET")
          end

          it "assigns the locality to address_line_2" do
            expect(address[:address_line_2]).to eq("LONDON")
          end
        end

        context "with a flat/unit number (org and premises are nil)" do
          let(:data) do
            {
              "address" => "FLAT 2, 15 HIGH STREET, LONDON, SW1A 1AA",
              "organisation" => nil,
              "premises" => nil,
              "street_address" => "HIGH STREET",
              "locality" => "LONDON"
            }
          end

          before { address.assign_house_number_and_address_lines(data) }

          it "extracts the flat and house number from the address field" do
            expect(address[:house_number]).to eq("FLAT 2, 15")
          end

          it "assigns the street_address to address_line_1" do
            expect(address[:address_line_1]).to eq("HIGH STREET")
          end
        end

        context "with a flat above a named building (org nil, premises present)" do
          let(:data) do
            {
              "address" => "FLAT 9, SUMMER COURT, WHEELER STREET, MAIDSTONE, ME14 2UX",
              "organisation" => nil,
              "premises" => "SUMMER COURT",
              "street_address" => "WHEELER STREET",
              "locality" => nil
            }
          end

          before { address.assign_house_number_and_address_lines(data) }

          it "keeps the flat detail from the address field" do
            expect(address[:house_number]).to eq("FLAT 9")
          end

          it "assigns premises to address_line_1" do
            expect(address[:address_line_1]).to eq("SUMMER COURT")
          end

          it "assigns street_address to address_line_2" do
            expect(address[:address_line_2]).to eq("WHEELER STREET")
          end
        end

        context "with more parts than there are address fields" do
          let(:data) do
            {
              "address" => "THE MANAGER, FLAT 3, ROSE COURT, 12 STATION APPROACH, HIGH STREET, LITTLE VILLAGE, BIGTOWN, AB1 2CD",
              "organisation" => "THE MANAGER",
              "premises" => "ROSE COURT",
              "street_address" => "HIGH STREET",
              "locality" => "LITTLE VILLAGE"
            }
          end

          before { address.assign_house_number_and_address_lines(data) }

          it "folds the surplus leading parts into house_number" do
            expect(address[:house_number]).to eq("THE MANAGER, FLAT 3")
          end

          it "assigns the remaining lines in order" do
            expect(address[:address_line_1]).to eq("ROSE COURT")
            expect(address[:address_line_2]).to eq("12 STATION APPROACH")
            expect(address[:address_line_3]).to eq("HIGH STREET")
            expect(address[:address_line_4]).to eq("LITTLE VILLAGE")
          end

          it "does not write any attribute with a blank key" do
            expect(address.attributes.keys).to all(be_present)
          end
        end

        context "with a business address (org/premises present)" do
          let(:data) do
            {
              "address" => "ENVIRONMENT AGENCY, HORIZON HOUSE, DEANERY ROAD, BRISTOL",
              "organisation" => "ENVIRONMENT AGENCY",
              "premises" => "HORIZON HOUSE",
              "street_address" => "DEANERY ROAD",
              "locality" => nil
            }
          end

          before { address.assign_house_number_and_address_lines(data) }

          it "uses organisation as house_number" do
            expect(address[:house_number]).to eq("ENVIRONMENT AGENCY")
          end

          it "assigns premises to address_line_1" do
            expect(address[:address_line_1]).to eq("HORIZON HOUSE")
          end

          it "assigns street_address to address_line_2" do
            expect(address[:address_line_2]).to eq("DEANERY ROAD")
          end
        end

        context "when address starts with street (no prefix to extract)" do
          let(:data) do
            {
              "address" => "HIGH STREET, LONDON, SW1A 1AA",
              "organisation" => nil,
              "premises" => nil,
              "street_address" => "HIGH STREET",
              "locality" => "LONDON"
            }
          end

          before { address.assign_house_number_and_address_lines(data) }

          it "falls back to using street_address as house_number" do
            expect(address[:house_number]).to eq("HIGH STREET")
          end

          it "assigns locality to address_line_1" do
            expect(address[:address_line_1]).to eq("LONDON")
          end
        end

        context "when only organisation is present (premises nil)" do
          let(:data) do
            {
              "address" => "ACME CORP, 123 MAIN STREET, LONDON",
              "organisation" => "ACME CORP",
              "premises" => nil,
              "street_address" => "MAIN STREET",
              "locality" => "LONDON"
            }
          end

          before { address.assign_house_number_and_address_lines(data) }

          it "assigns organisation as house_number" do
            expect(address[:house_number]).to eq("ACME CORP")
          end

          it "keeps the building number from the address field" do
            expect(address[:address_line_1]).to eq("123")
          end

          it "assigns street_address to address_line_2" do
            expect(address[:address_line_2]).to eq("MAIN STREET")
          end

          it "assigns locality to address_line_3" do
            expect(address[:address_line_3]).to eq("LONDON")
          end
        end
      end
    end

    describe ".create_from_os_places_data" do
      let(:os_places_data) { JSON.parse(file_fixture("os_api_response.json").read) }
      let(:created_address) { instance_double(described_class) }

      subject(:address_from_os_places) { described_class.create_from_os_places_data(os_places_data) }

      it { expect(address_from_os_places).to be_a(described_class) }

      it "calls the update_from_os_places_data method to assign the attributes" do
        allow(described_class).to receive(:new).and_return(created_address)
        allow(created_address).to receive(:update_from_os_places_data)

        address_from_os_places

        expect(created_address).to have_received(:update_from_os_places_data)
      end
    end

    describe "#update_from_os_places_data" do
      let(:os_places_data) { JSON.parse(file_fixture("os_api_response.json").read) }
      let(:address_to_update) { build(:address) }

      subject(:updated_address) { address_to_update.update_from_os_places_data(os_places_data) }

      context "with all relevant fields populated in the OS places response" do
        before do
          os_places_data["locality"] = "SOUTH BRISTOL"
        end

        it "includes the correct values" do
          expect(updated_address.attributes).to include(
            "uprn" => os_places_data["uprn"],
            "houseNumber" => os_places_data["organisation"],
            "addressLine1" => os_places_data["premises"],
            "addressLine2" => os_places_data["street_address"],
            "addressLine3" => os_places_data["locality"],
            "townCity" => os_places_data["city"],
            "postcode" => os_places_data["postcode"],
            "country" => os_places_data["country"],
            "dependentLocality" => os_places_data["locality"],
            "administrativeArea" => os_places_data["city"],
            "localAuthorityUpdateDate" => os_places_data["last_update_date"],
            "easting" => os_places_data["x"].to_i,
            "northing" => os_places_data["y"].to_i,
            "addressMode" => "address-results"
          )
        end

        it "does not have nil keys" do
          expect(updated_address.attributes.keys).not_to include(nil)
        end
      end

      context "with locality nil (fixture default)" do
        it "assigns available fields without locality" do
          expect(updated_address[:house_number]).to eq(os_places_data["organisation"])
          expect(updated_address[:address_line_1]).to eq(os_places_data["premises"])
          expect(updated_address[:address_line_2]).to eq(os_places_data["street_address"])
          expect(updated_address[:address_line_3]).to be_nil
        end
      end

      context "with some optional fields missing" do
        before do
          os_places_data["organisation"] = nil
          os_places_data["locality"] = "SOUTH BRISTOL"
          # Update address to be consistent (no organisation prefix)
          os_places_data["address"] = "HORIZON HOUSE, DEANERY ROAD, BRISTOL, BS1 5AH"
        end

        it "skips the missing field when assigning address lines" do
          expect(updated_address[:house_number]).to eq(os_places_data["premises"])
          expect(updated_address[:address_line_1]).to eq(os_places_data["street_address"])
          expect(updated_address[:address_line_2]).to eq(os_places_data["locality"])
        end
      end

      context "with only street_address and locality" do
        before do
          os_places_data["organisation"] = nil
          os_places_data["premises"] = nil
          os_places_data["locality"] = "SOUTH BRISTOL"
          # Update address to be consistent with residential (no org/premises prefix)
          os_places_data["address"] = "DEANERY ROAD, SOUTH BRISTOL, BS1 5AH"
        end

        it "assigns available fields starting from house_number" do
          expect(updated_address[:house_number]).to eq(os_places_data["street_address"])
          expect(updated_address[:address_line_1]).to eq(os_places_data["locality"])
          expect(updated_address[:address_line_2]).to be_nil
        end
      end
    end
  end
end
