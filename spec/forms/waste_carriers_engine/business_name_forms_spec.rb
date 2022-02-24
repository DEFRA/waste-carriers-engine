# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe BusinessNameForm, type: :model do
    describe "#submit" do
      context "when the form is valid" do
        let(:business_name_form) { build(:business_name_form, :has_required_data) }
        let(:valid_params) do
          { token: business_name_form.token, business_name: business_name_form.business_name }
        end

        it "should submit" do
          expect(business_name_form.submit(valid_params)).to eq(true)
        end
      end

      context "when the form is not valid" do
        let(:business_name_form) { build(:business_name_form, :has_required_data) }
        let(:invalid_params) { { business_name: "" } }

        it "should not submit" do
          expect(business_name_form.submit(invalid_params)).to eq(false)
        end
      end
    end

    include_examples "validate business_name", :business_name_form
  end
end
