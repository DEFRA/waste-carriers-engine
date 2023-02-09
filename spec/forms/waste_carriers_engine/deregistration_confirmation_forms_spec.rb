# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe DeregistrationConfirmationForm do
    describe "#submit" do
      let(:deregistration_confirmation_form) { build(:deregistration_confirmation_form) }
      let(:original_registration) { deregistration_confirmation_form.transient_registration.registration }
      let(:selected_option) { "no" }

      before { allow(WasteCarriersEngine.configuration).to receive(:host_is_back_office?).and_return false }

      context "when the form is valid" do
        let(:valid_params) do
          {
            token: deregistration_confirmation_form.token,
            temp_confirm_deregistration: selected_option
          }
        end

        context "when 'No' is selected" do
          let(:selected_option) { "no" }

          it "submits" do
            expect(deregistration_confirmation_form.submit(valid_params)).to be true
          end
        end

        context "when 'Yes' is selected" do
          let(:selected_option) { "yes" }

          it "submits" do
            expect(deregistration_confirmation_form.submit(valid_params)).to be true
          end
        end
      end

      context "when the form is not valid" do
        let(:invalid_params) do
          {
            token: "foo",
            temp_confirm_deregistration: nil
          }
        end

        it "does not submit" do
          expect(deregistration_confirmation_form.submit(invalid_params)).to be false
        end
      end
    end
  end
end
