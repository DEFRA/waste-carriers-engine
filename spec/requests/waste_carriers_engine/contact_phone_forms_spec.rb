# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "ContactPhoneForms", type: :request do
    include_examples "GET flexible form", "contact_phone_form"

    describe "POST contact_phone_form_path" do
      include_examples "POST renewal form",
                       "contact_phone_form",
                       valid_params: { phone_number: "01234 567890" },
                       invalid_params: { phone_number: "foo" },
                       test_attribute: :phone_number

      context "When the transient_registration is a new registration" do
        let(:transient_registration) do
          create(:new_registration, workflow_state: "contact_phone_form")
        end

        include_examples "POST form",
                         "contact_phone_form",
                         valid_params: { phone_number: "01234 567890" },
                         invalid_params: { phone_number: "foo" }
      end
    end

    describe "GET back_contact_phone_forms_path" do
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
                   workflow_state: "contact_phone_form")
          end

          context "when the back action is triggered" do
            it "returns a 302 response and redirects to the contact_name form" do
              get back_contact_phone_forms_path(transient_registration.token)

              expect(response).to have_http_status(302)
              expect(response).to redirect_to(new_contact_name_form_path(transient_registration.token))
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
              get back_contact_phone_forms_path(transient_registration.token)

              expect(response).to have_http_status(302)
              expect(response).to redirect_to(new_renewal_start_form_path(transient_registration.token))
            end
          end
        end
      end
    end
  end
end
