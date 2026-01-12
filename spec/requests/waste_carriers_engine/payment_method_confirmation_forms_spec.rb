# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "PaymentMethodConfirmationForms" do
    it_behaves_like "GET locked-in form", "payment_method_confirmation_form"

    describe "POST payment_method_confirmation_form_path" do
      let(:confirmation_response) { "yes" }
      let(:invalid_params) { { temp_confirm_payment_method: "foo" } }
      let(:govpay_host) { "https://publicapi.payments.service.gov.uk" }

      shared_examples "redirects based on the confirmation response" do

        before do
          stub_request(:any, /.*#{govpay_host}.*/).to_return(
            status: 200,
            body: File.read("./spec/fixtures/files/govpay/create_payment_created_response.json")
          )
        end

        context "when the response is yes" do
          let(:valid_params) { { temp_confirm_payment_method: "yes" } }

          it "redirects to the govpay form" do
            post payment_method_confirmation_forms_path(transient_registration.token),
                 params: { payment_method_confirmation_form: valid_params }

            expect(response).to redirect_to(new_govpay_form_path(transient_registration[:token]))
          end

          # If we land on this page with temp_govpay_next_url already set,
          # most likely the payment has payed on Gov.UK Pay and we've been redirected back.
          # So the existing transaction on Gov.UK Pay is in a terminal state.
          # So we need to start a new Gov.UK Pay payment.
          context "when temp_govpay_next_url is not already set" do
            before { transient_registration.update(temp_govpay_next_url: nil) }

            it "does not update temp_govpay_next_url" do
              expect do
                post payment_method_confirmation_forms_path(transient_registration.token)
              end.not_to change(transient_registration, :temp_govpay_next_url)
            end
          end

          context "when temp_govpay_next_url is already set" do
            before { transient_registration.update(temp_govpay_next_url: Faker::Internet.url) }

            it "creates a new payment on Gov.UK Pay and updates temp_govpay_next_url" do
              expect do
                post payment_method_confirmation_forms_path(transient_registration.token)
              end.to change { transient_registration.reload.temp_govpay_next_url }
            end
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
                 :has_finance_details,
                 from_magic_link: true,
                 workflow_state: "payment_method_confirmation_form",
                 temp_payment_method: "card")
        end

        it_behaves_like "POST renewal form",
                        "payment_method_confirmation_form",
                        valid_params: { temp_confirm_payment_method: "yes" },
                        invalid_params: { temp_confirm_payment_method: "foo" },
                        test_attribute: :temp_confirm_payment_method

        it_behaves_like "redirects based on the confirmation response"
      end

      context "when the transient_registration is a new registration" do
        let(:transient_registration) do
          create(:new_registration,
                 :has_paid_finance_details,
                 workflow_state: "payment_method_confirmation_form",
                 temp_payment_method: "card")
        end

        it_behaves_like "POST form",
                        "payment_method_confirmation_form",
                        valid_params: { temp_confirm_payment_method: "no" },
                        invalid_params: { temp_confirm_payment_method: "foo" },
                        test_attribute: :temp_confirm_payment_method

        it_behaves_like "redirects based on the confirmation response"
      end
    end
  end
end
