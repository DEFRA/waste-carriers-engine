require "rails_helper"

RSpec.describe Address, type: :model do
  let(:address) { build(:address) }

  describe "assign_address_lines" do
    context "when it is given address data" do
      let(:data) do
        {
          "organisationName" => "Foo Industries",
          "subBuildingName" => "Suite 5",
          "buildingName" => "The Bar Building",
          "buildingNumber" => "5",
          "thoroughfareName" => "Baz Street"
        }
      end

      it "should assign the correct address lines" do
        address.assign_address_lines(data)
        expect(address[:address_line_1]).to eq("Foo Industries")
        expect(address[:address_line_2]).to eq("Suite 5")
        expect(address[:address_line_3]).to eq("The Bar Building")
        expect(address[:address_line_4]).to eq("5 Baz Street")
      end

      context "when not all address fields are used" do
        before { data["buildingName"] = "" }

        it "should skip blank fields when assigning lines" do
          address.assign_address_lines(data)
          expect(address[:address_line_1]).to eq("Foo Industries")
          expect(address[:address_line_2]).to eq("Suite 5")
          expect(address[:address_line_3]).to eq("5 Baz Street")
        end
      end
    end
  end
end
