# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe WasteTypesForm do
    describe "#submit" do
      context "when the form is valid" do
        let(:waste_types_form) { build(:waste_types_form, :has_required_data) }
        let(:valid_params) do
          {
            token: waste_types_form.token,
            only_amf: waste_types_form.only_amf
          }
        end

        it "submits" do
          expect(waste_types_form.submit(valid_params)).to be true
        end
      end

      context "when the form is not valid" do
        let(:waste_types_form) { build(:waste_types_form, :has_required_data) }
        let(:invalid_params) { { only_amf: "foo" } }

        it "does not submit" do
          expect(waste_types_form.submit(invalid_params)).to be false
        end
      end
    end

    include_examples "validate yes no", :waste_types_form, :only_amf
  end
end
