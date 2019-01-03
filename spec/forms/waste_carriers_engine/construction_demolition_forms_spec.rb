# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe ConstructionDemolitionForm, type: :model do
    describe "#submit" do
      context "when the form is valid" do
        let(:construction_demolition_form) { build(:construction_demolition_form, :has_required_data) }
        let(:valid_params) do
          {
            reg_identifier: construction_demolition_form.reg_identifier,
            construction_waste: construction_demolition_form.construction_waste
          }
        end

        it "should submit" do
          expect(construction_demolition_form.submit(valid_params)).to eq(true)
        end
      end

      context "when the form is not valid" do
        let(:construction_demolition_form) { build(:construction_demolition_form, :has_required_data) }
        let(:invalid_params) { { reg_identifier: "foo" } }

        it "should not submit" do
          expect(construction_demolition_form.submit(invalid_params)).to eq(false)
        end
      end
    end

    include_examples "validate yes no", :construction_demolition_form, :construction_waste
  end
end
