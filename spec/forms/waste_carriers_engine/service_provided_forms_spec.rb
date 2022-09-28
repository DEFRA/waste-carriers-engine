# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe ServiceProvidedForm, type: :model do
    describe "#submit" do
      context "when the form is valid" do
        let(:service_provided_form) { build(:service_provided_form, :has_required_data) }
        let(:valid_params) do
          {
            token: service_provided_form.token,
            is_main_service: service_provided_form.is_main_service
          }
        end

        it "submits" do
          expect(service_provided_form.submit(valid_params)).to be true
        end
      end

      context "when the form is not valid" do
        let(:service_provided_form) { build(:service_provided_form, :has_required_data) }
        let(:invalid_params) { { is_main_service: "foo" } }

        it "does not submit" do
          expect(service_provided_form.submit(invalid_params)).to be false
        end
      end
    end

    include_examples "validate yes no", :service_provided_form, :is_main_service
  end
end
