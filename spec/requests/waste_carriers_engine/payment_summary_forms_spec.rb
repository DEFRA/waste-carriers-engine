# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "PaymentSummaryForms", type: :request do
    include_examples "GET locked-in form", "payment_summary_form"

    include_examples "POST form",
                     "payment_summary_form",
                     valid_params: { temp_payment_method: "card" },
                     invalid_params: { temp_payment_method: "foo" },
                     test_attribute: :temp_payment_method

    describe "GET back_payment_summary_forms_path" do
      context "when a valid user is signed in" do
        let(:user) { create(:user) }
        before(:each) do
          sign_in(user)
        end

        context "when a valid transient registration exists" do
          let(:transient_registration) do
            create(:transient_registration,
                   :has_required_data,
                   account_email: user.email,
                   workflow_state: "payment_summary_form")
          end

          context "when the back action is triggered" do
            it "returns a 302 response" do
              get back_payment_summary_forms_path(transient_registration[:reg_identifier])
              expect(response).to have_http_status(302)
            end

            it "redirects to the cards form" do
              get back_payment_summary_forms_path(transient_registration[:reg_identifier])
              expect(response).to redirect_to(new_cards_form_path(transient_registration[:reg_identifier]))
            end
          end
        end

        context "when the transient registration is in the wrong state" do
          let(:transient_registration) do
            create(:transient_registration,
                   :has_required_data,
                   account_email: user.email,
                   workflow_state: "renewal_start_form")
          end

          context "when the back action is triggered" do
            it "returns a 302 response" do
              get back_payment_summary_forms_path(transient_registration[:reg_identifier])
              expect(response).to have_http_status(302)
            end

            it "redirects to the correct form for the state" do
              get back_payment_summary_forms_path(transient_registration[:reg_identifier])
              expect(response).to redirect_to(new_renewal_start_form_path(transient_registration[:reg_identifier]))
            end
          end
        end
      end
    end
  end
end
