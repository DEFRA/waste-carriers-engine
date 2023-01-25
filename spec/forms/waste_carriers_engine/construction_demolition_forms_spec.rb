# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe ConstructionDemolitionForm do
    describe "#submit" do
      context "when the form is valid" do
        let(:construction_demolition_form) { build(:construction_demolition_form, :has_required_data) }
        let(:valid_params) do
          {
            token: construction_demolition_form.token,
            construction_waste: construction_demolition_form.construction_waste
          }
        end

        it "submits" do
          expect(construction_demolition_form.submit(valid_params)).to be true
        end
      end

      context "when the form is not valid" do
        let(:construction_demolition_form) { build(:construction_demolition_form, :has_required_data) }
        let(:invalid_params) { { construction_waste: "foo" } }

        it "does not submit" do
          expect(construction_demolition_form.submit(invalid_params)).to be false
        end
      end
    end

    include_examples "validate yes no", :construction_demolition_form, :construction_waste
  end
end
