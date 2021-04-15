# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe Address, type: :model do
    describe "assign_house_number_and_address_lines" do
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
  end
end
