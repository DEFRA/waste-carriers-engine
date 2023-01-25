# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe OtherBusinessesForm do
    describe "#submit" do
      context "when the form is valid" do
        let(:other_businesses_form) { build(:other_businesses_form, :has_required_data) }
        let(:valid_params) do
          {
            token: other_businesses_form.token,
            other_businesses: other_businesses_form.other_businesses
          }
        end

        it "submits" do
          expect(other_businesses_form.submit(valid_params)).to be true
        end
      end

      context "when the form is not valid" do
        let(:other_businesses_form) { build(:other_businesses_form, :has_required_data) }
        let(:invalid_params) { { other_businesses: "foo" } }

        it "does not submit" do
          expect(other_businesses_form.submit(invalid_params)).to be false
        end
      end
    end

    include_examples "validate yes no", :other_businesses_form, :other_businesses
  end
end
