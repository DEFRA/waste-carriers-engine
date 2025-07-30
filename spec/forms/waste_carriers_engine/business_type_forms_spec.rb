# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe BusinessTypeForm do
    describe "#submit" do
      context "when the form is valid" do
        let(:business_type_form) { build(:business_type_form, :has_required_data) }
        let(:valid_params) { { token: business_type_form.token, business_type: "limitedCompany" } }

        it "submits" do
          expect(business_type_form.submit(valid_params)).to be true
        end
      end

      context "when the form is not valid" do
        let(:business_type_form) { build(:business_type_form, :has_required_data) }
        let(:invalid_params) { { token: "foo", business_type: "foo" } }

        it "does not submit" do
          expect(business_type_form.submit(invalid_params)).to be false
        end
      end
    end

    it_behaves_like "validate business_type", :business_type_form
  end
end
