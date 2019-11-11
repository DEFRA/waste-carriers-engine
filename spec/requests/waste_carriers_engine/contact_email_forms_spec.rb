# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "ContactEmailForms", type: :request do
    include_examples "GET flexible form", "contact_email_form"

    include_examples "POST form",
                     "contact_email_form",
                     valid_params: { contact_email: "bar.baz@example.com",
                                     confirmed_email: "bar.baz@example.com" },
                     invalid_params: { contact_email: "bar",
                                       confirmed_email: "baz" },
                     test_attribute: :contact_email

    describe "GET back_contact_email_forms_path" do
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
                   workflow_state: "contact_email_form")
          end

          context "when the back action is triggered" do
            it "returns a 302 response" do
              get back_contact_email_forms_path(transient_registration[:reg_identifier])
              expect(response).to have_http_status(302)
            end

            it "redirects to the contact_phone form" do
              get back_contact_email_forms_path(transient_registration[:reg_identifier])
              expect(response).to redirect_to(new_contact_phone_form_path(transient_registration[:reg_identifier]))
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
            it "returns a 302 response" do
              get back_contact_email_forms_path(transient_registration[:reg_identifier])
              expect(response).to have_http_status(302)
            end

            it "redirects to the correct form for the state" do
              get back_contact_email_forms_path(transient_registration[:reg_identifier])
              expect(response).to redirect_to(new_renewal_start_form_path(transient_registration[:reg_identifier]))
            end
          end
        end
      end
    end
  end
end
