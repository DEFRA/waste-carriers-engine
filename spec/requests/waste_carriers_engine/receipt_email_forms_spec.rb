# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "ReceiptEmailForms", type: :request do
    include_examples "GET flexible form", "receipt_email_form"

    describe "POST receipt_email_form_path" do
      include_examples "POST renewal form",
                       "receipt_email_form",
                       valid_params: { receipt_email: "foo@example.com" },
                       invalid_params: { receipt_email: "foo" },
                       test_attribute: :receipt_email

      context "When the transient_registration is a new registration" do
        let(:transient_registration) do
          create(:new_registration, workflow_state: "receipt_email_form")
        end

        include_examples "POST form",
                         "receipt_email_form",
                         valid_params: { receipt_email: "foo@example.com" },
                         invalid_params: { receipt_email: "foo" }
      end
    end

    describe "GET back_receipt_email_forms_path" do
      context "when a valid user is signed in" do
        let(:user) { create(:user) }
        before(:each) do
          sign_in(user)
        end

        context "when a valid transient registration exists" do
          let(:transient_registration) do
            create(:renewing_registration,
                   :has_required_data,
                   account_email: user.email,
                   workflow_state: "receipt_email_form")
          end

          context "when the back action is triggered" do
            it "returns a 302 response and redirects to the cards form" do
              get back_receipt_email_forms_path(transient_registration[:token])

              expect(response).to have_http_status(302)
              expect(response).to redirect_to(new_cards_form_path(transient_registration[:token]))
            end
          end
        end

        context "when the transient registration is in the wrong state" do
          let(:transient_registration) do
            create(:renewing_registration,
                   :has_required_data,
                   account_email: user.email,
                   workflow_state: "renewal_start_form")
          end

          context "when the back action is triggered" do
            it "returns a 302 response and redirects to the correct form for the state" do
              get back_receipt_email_forms_path(transient_registration[:token])

              expect(response).to have_http_status(302)
              expect(response).to redirect_to(new_renewal_start_form_path(transient_registration[:token]))
            end
          end
        end
      end
    end
  end
end
