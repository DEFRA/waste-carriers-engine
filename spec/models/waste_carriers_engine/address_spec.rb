require "rails_helper"

module WasteCarriersEngine
  RSpec.describe Address, type: :model do
    let(:address) { build(:address) }

    describe "assign_address_lines" do
      context "when it is given address data" do
        let(:data) do
          {
            "buildingName" => "Foo Buildings",
            "buildingNumber" => "5",
            "dependentLocality" => "Baz Village",
            "thoroughfareName" => "Bar Street",
            "lines" => [
              "FOO BUILDINGS",
              "BAR STREET",
              "BAZ VILLAGE"
            ]
          }
        end

        it "should assign the correct address lines" do
          address.assign_address_lines(data)
          expect(address[:address_line_1]).to eq("5")
          expect(address[:address_line_2]).to eq("FOO BUILDINGS")
          expect(address[:address_line_3]).to eq("BAR STREET")
          expect(address[:address_line_4]).to eq("BAZ VILLAGE")
        end

        context "when the buildingNumber is not used" do
          before do
            data.delete("buildingNumber")
          end

          it "should skip blank fields when assigning lines" do
            address.assign_address_lines(data)
            expect(address[:address_line_1]).to eq("FOO BUILDINGS")
            expect(address[:address_line_2]).to eq("BAR STREET")
            expect(address[:address_line_3]).to eq("BAZ VILLAGE")
            expect(address[:address_line_4].present?).to eq(false)
          end
        end

        context "when the lines are not all used" do
          before do
            data["lines"] = ["FOO BUILDINGS", "BAR STREET"]
          end

          it "should skip blank fields when assigning lines" do
            address.assign_address_lines(data)
            expect(address[:address_line_1]).to eq("5")
            expect(address[:address_line_2]).to eq("FOO BUILDINGS")
            expect(address[:address_line_3]).to eq("BAR STREET")
            expect(address[:address_line_4].present?).to eq(false)
          end
        end
      end
    end
  end
end
