# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "PaymentMethodConfirmationForms" do
    include_examples "GET locked-in form", "payment_method_confirmation_form"

    describe "POST payment_method_confirmation_form_path" do
      let(:confirmation_response) { "yes" }
      let(:invalid_params) { { temp_confirm_payment_method: "foo" } }
      # let(:user) { create(:user) }

      # before { sign_in(user) }

      shared_examples "redirects based on the confirmation response" do

        context "when the response is yes" do
          let(:valid_params) { { temp_confirm_payment_method: "yes" } }

          it "redirects to the govpay form" do
            post payment_method_confirmation_forms_path(transient_registration.token),
                 params: { payment_method_confirmation_form: valid_params }

            expect(response).to redirect_to(new_govpay_form_path(transient_registration[:token]))
          end
        end

        context "when the response is no" do
          let(:valid_params) { { temp_confirm_payment_method: "no" } }

          it "redirects to the payment summary form" do
            post payment_method_confirmation_forms_path(transient_registration.token),
                 params: { payment_method_confirmation_form: valid_params }

            expect(response).to redirect_to(new_payment_summary_form_path(transient_registration[:token]))
          end
        end
      end

      context "when the transient_registration is a renewing registration" do
        let(:transient_registration) do
          create(:renewing_registration,
                 from_magic_link: true,
                 workflow_state: "payment_method_confirmation_form",
                 temp_payment_method: "card")
        end

        include_examples "POST renewal form",
                         "payment_method_confirmation_form",
                         valid_params: { temp_confirm_payment_method: "yes" },
                         invalid_params: { temp_confirm_payment_method: "foo" },
                         test_attribute: :temp_confirm_payment_method

        it_behaves_like "redirects based on the confirmation response"
      end

      context "when the transient_registration is a new registration" do
        let(:transient_registration) do
          create(:new_registration, workflow_state: "payment_method_confirmation_form", temp_payment_method: "card")
        end

        include_examples "POST form",
                         "payment_method_confirmation_form",
                         valid_params: { temp_confirm_payment_method: "no" },
                         invalid_params: { temp_confirm_payment_method: "foo" },
                         test_attribute: :temp_confirm_payment_method

        it_behaves_like "redirects based on the confirmation response"
      end
    end
  end
end
