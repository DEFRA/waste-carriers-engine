# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe OtherBusinessesForm, type: :model do
    describe "#submit" do
      context "when the form is valid" do
        let(:other_businesses_form) { build(:other_businesses_form, :has_required_data) }
        let(:valid_params) do
          {
            reg_identifier: other_businesses_form.reg_identifier,
            other_businesses: other_businesses_form.other_businesses
          }
        end

        it "should submit" do
          expect(other_businesses_form.submit(valid_params)).to eq(true)
        end
      end

      context "when the form is not valid" do
        let(:other_businesses_form) { build(:other_businesses_form, :has_required_data) }
        let(:invalid_params) { { reg_identifier: "foo" } }

        it "should not submit" do
          expect(other_businesses_form.submit(invalid_params)).to eq(false)
        end
      end
    end

    include_examples "validate yes no", :other_businesses_form, :other_businesses
  end
end
