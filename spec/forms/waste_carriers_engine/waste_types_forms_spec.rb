# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe WasteTypesForm, type: :model do
    describe "#submit" do
      context "when the form is valid" do
        let(:waste_types_form) { build(:waste_types_form, :has_required_data) }
        let(:valid_params) do
          {
            reg_identifier: waste_types_form.reg_identifier,
            only_amf: waste_types_form.only_amf
          }
        end

        it "should submit" do
          expect(waste_types_form.submit(valid_params)).to eq(true)
        end
      end

      context "when the form is not valid" do
        let(:waste_types_form) { build(:waste_types_form, :has_required_data) }
        let(:invalid_params) { { reg_identifier: "foo" } }

        it "should not submit" do
          expect(waste_types_form.submit(invalid_params)).to eq(false)
        end
      end
    end

    include_examples "validate yes no", :waste_types_form, :only_amf
  end
end
