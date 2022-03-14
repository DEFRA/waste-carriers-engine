# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe Address, type: :model do
    describe "#assign_house_number_and_address_lines" do
      let(:address) { build(:address) }

      context "when it is given address data" do
        let(:data) do
          {
            "lines" => [
              "FOO HOUSE",
              "BAR BUILDINGS",
              "BAZ STREET",
              "QUX CORNER",
              "QUUX VILLAGE"
            ]
          }
        end

        context "when all the lines are used" do
          before do
            address.assign_house_number_and_address_lines(data)
          end

          it "should assign the correct house_number" do
            expect(address[:house_number]).to eq("FOO HOUSE")
          end

          it "should assign the correct address_lines" do
            expect(address[:address_line_1]).to eq("BAR BUILDINGS")
            expect(address[:address_line_2]).to eq("BAZ STREET")
            expect(address[:address_line_3]).to eq("QUX CORNER")
            expect(address[:address_line_4]).to eq("QUUX VILLAGE")
          end
        end

        context "when the lines are not all used" do
          before do
            data["lines"] = ["FOO BUILDINGS", "BAR STREET"]
            address.assign_house_number_and_address_lines(data)
          end

          it "should assign the correct house_number" do
            expect(address[:house_number]).to eq("FOO BUILDINGS")
          end

          it "should skip blank fields when assigning lines" do
            expect(address[:address_line_1]).to eq("BAR STREET")
            expect(address[:address_line_2].present?).to eq(false)
            expect(address[:address_line_3].present?).to eq(false)
            expect(address[:address_line_4].present?).to eq(false)
          end
        end
      end
    end

    describe ".create_from_os_places_data" do
      let(:os_places_data) { JSON.parse(file_fixture("os_places_response.json").read) }
      let(:os_lines) { os_places_data["lines"] }
      subject { described_class.create_from_os_places_data(os_places_data) }

      RSpec.shared_examples "address fields" do
        it "includes the expected fields" do
          %i[uprn address_mode administrative_area administrative_area easting northing
             house_number address_line_1 town_city postcode].each do |field|
            expect(subject[field]).to be_present
          end
        end

        it "populates house number and address fields correctly" do
          # use 'expect(x==y).to be_truthy' instead of 'expect(x).to eq(y)' to allow for nil values.
          expect(subject[:house_number]   == expected_house_address_lines[0]).to be_truthy
          expect(subject[:address_line_1] == expected_house_address_lines[1]).to be_truthy
          expect(subject[:address_line_2] == expected_house_address_lines[2]).to be_truthy
          expect(subject[:address_line_3] == expected_house_address_lines[3]).to be_truthy
          expect(subject[:address_line_4] == expected_house_address_lines[4]).to be_truthy
          expect(subject[:address_line_5] == expected_house_address_lines[5]).to be_truthy
        end
      end

      context "with no dependent thoroughfare or building name" do
        before do
          os_places_data["dependentThoroughfare"] = ""
          os_places_data["buildingName"] = ""
        end

        context "with few address lines returned by OS places" do
          let(:expected_house_address_lines) { [os_lines[0..1], [nil] * 4].flatten }

          it_behaves_like "address fields"
        end

        context "with all address lines returned by OS places" do
          before do
            os_places_data["lines"] << Faker::Address.street_name while os_places_data["lines"].length < 6
          end
          let(:expected_house_address_lines) { os_lines[0..5] }

          it_behaves_like "address fields"
        end
      end

      context "with a dependent thoroughfare and no building name" do
        let(:dependent_thoroughfare) { Faker::Address.street_name }
        before do
          os_places_data["dependentThoroughfare"] = dependent_thoroughfare
          os_places_data["buildingName"] = ""
        end

        context "with few address lines returned by OS places" do
          let(:expected_house_address_lines) do
            [
              os_lines[0],
              dependent_thoroughfare,
              os_places_data["thoroughfareName"],
              [nil] * 3
            ].flatten
          end

          it_behaves_like "address fields"
        end

        context "with all address lines returned by OS places" do
          before do
            os_places_data["lines"] << Faker::Address.street_name while os_places_data["lines"].length < 6
          end

          let(:expected_house_address_lines) do
            [
              os_lines[0],
              dependent_thoroughfare,
              os_places_data["thoroughfareName"],
              [os_lines[2..4]]
            ].flatten
          end

          it_behaves_like "address fields"
        end
      end

      context "with a building name and no dependent thoroughfare" do
        let(:building_name) { Faker::Address.secondary_address }
        before do
          os_places_data["dependentThoroughfare"] = ""
          os_places_data["buildingName"] = building_name
        end

        context "with few address lines returned by OS places" do
          let(:expected_house_address_lines) do
            [
              os_lines[0],
              building_name,
              os_places_data["thoroughfareName"],
              [nil] * 3
            ].flatten
          end

          it_behaves_like "address fields"
        end

        context "with all address lines returned by OS places" do
          before do
            os_places_data["lines"] << Faker::Address.street_name while os_places_data["lines"].length < 6
          end

          let(:expected_house_address_lines) do
            [
              os_lines[0],
              building_name,
              os_places_data["thoroughfareName"],
              [os_lines[2..4]]
            ].flatten
          end

          it_behaves_like "address fields"
        end
      end

      context "with a dependent thoroughfare and a building name" do
        let(:dependent_thoroughfare) { Faker::Address.street_name }
        let(:building_name) { Faker::Address.secondary_address }
        before do
          os_places_data["dependentThoroughfare"] = dependent_thoroughfare
          os_places_data["buildingName"] = building_name
        end

        context "with few address lines returned by OS places" do
          let(:expected_house_address_lines) do
            [
              os_lines[0],
              building_name,
              dependent_thoroughfare,
              os_places_data["thoroughfareName"],
              [nil] * 2
            ].flatten
          end

          it_behaves_like "address fields"
        end

        context "with all address lines returned by OS places" do
          before do
            os_places_data["lines"] << Faker::Address.street_name while os_places_data["lines"].length < 6
          end

          let(:expected_house_address_lines) do
            [
              os_lines[0],
              building_name,
              dependent_thoroughfare,
              os_places_data["thoroughfareName"],
              [os_lines[2..3]]
            ].flatten
          end

          it_behaves_like "address fields"
        end
      end
    end
  end
end
