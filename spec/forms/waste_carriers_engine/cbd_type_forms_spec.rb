# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe CbdTypeForm do
    describe "#submit" do
      context "when the form is valid" do
        let(:cbd_type_form) { build(:cbd_type_form, :has_required_data) }
        let(:valid_params) { { token: cbd_type_form.token, registration_type: cbd_type_form.registration_type } }

        it "submits" do
          expect(cbd_type_form.submit(valid_params)).to be true
        end
      end

      context "when the form is not valid" do
        let(:cbd_type_form) { build(:cbd_type_form, :has_required_data) }
        let(:invalid_params) { { token: "foo", registration_type: "bar" } }

        it "does not submit" do
          expect(cbd_type_form.submit(invalid_params)).to be false
        end
      end
    end

    include_examples "validate registration_type", :cbd_type_form
  end
end
