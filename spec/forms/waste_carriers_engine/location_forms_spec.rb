# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe LocationForm, type: :model do
    describe "#submit" do
      context "when the form is valid" do
        let(:location_form) { build(:location_form, :has_required_data) }
        let(:valid_params) do
          {
            token: location_form.token,
            location: location_form.location
          }
        end

        it "submits" do
          expect(location_form.submit(valid_params)).to eq(true)
        end
      end

      context "when the form is not valid" do
        let(:location_form) { build(:location_form, :has_required_data) }
        let(:invalid_params) { { location: "foo" } }

        it "does not submit" do
          expect(location_form.submit(invalid_params)).to eq(false)
        end
      end
    end

    include_examples "validate location", :location_form
  end
end
