# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe PaymentMethodConfirmationForm do
    describe "#submit" do
      context "when the form is valid" do
        let(:payment_method_confirmation_form) { build(:payment_method_confirmation_form, :has_required_data) }
        let(:valid_params) do
          {
            token: payment_method_confirmation_form.token,
            temp_confirm_payment_method: payment_method_confirmation_form.temp_confirm_payment_method
          }
        end

        it "submits" do
          expect(payment_method_confirmation_form.submit(valid_params)).to be true
        end
      end

      context "when the form is not valid" do
        let(:payment_method_confirmation_form) { build(:payment_method_confirmation_form, :has_required_data) }
        let(:invalid_params) { { temp_confirm_payment_method: "foo" } }

        it "does not submit" do
          expect(payment_method_confirmation_form.submit(invalid_params)).to be false
        end
      end
    end

    it_behaves_like "validate yes no", :payment_method_confirmation_form, :temp_confirm_payment_method
  end
end
