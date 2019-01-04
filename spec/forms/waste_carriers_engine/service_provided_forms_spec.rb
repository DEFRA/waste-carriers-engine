# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe ServiceProvidedForm, type: :model do
    describe "#submit" do
      context "when the form is valid" do
        let(:service_provided_form) { build(:service_provided_form, :has_required_data) }
        let(:valid_params) do
          {
            reg_identifier: service_provided_form.reg_identifier,
            is_main_service: service_provided_form.is_main_service
          }
        end

        it "should submit" do
          expect(service_provided_form.submit(valid_params)).to eq(true)
        end
      end

      context "when the form is not valid" do
        let(:service_provided_form) { build(:service_provided_form, :has_required_data) }
        let(:invalid_params) { { reg_identifier: "foo" } }

        it "should not submit" do
          expect(service_provided_form.submit(invalid_params)).to eq(false)
        end
      end
    end

    include_examples "validate yes no", :service_provided_form, :is_main_service
  end
end
