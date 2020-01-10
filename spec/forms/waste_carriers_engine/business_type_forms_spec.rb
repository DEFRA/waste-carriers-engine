# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe BusinessTypeForm, type: :model do
    describe "#submit" do
      context "when the form is valid" do
        let(:business_type_form) { build(:business_type_form, :has_required_data) }
        let(:valid_params) { { _id: business_type_form._id, business_type: "limitedCompany" } }

        it "should submit" do
          expect(business_type_form.submit(valid_params)).to eq(true)
        end
      end

      context "when the form is not valid" do
        let(:business_type_form) { build(:business_type_form, :has_required_data) }
        let(:invalid_params) { { _id: "foo", business_type: "foo" } }

        it "should not submit" do
          expect(business_type_form.submit(invalid_params)).to eq(false)
        end
      end
    end

    include_examples "validate business_type", :business_type_form
  end
end
