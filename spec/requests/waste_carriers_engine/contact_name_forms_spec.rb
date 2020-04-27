# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "ContactNameForms", type: :request do
    include_examples "GET flexible form", "contact_name_form"

    describe "POST contact_name_form_path" do
      include_examples "POST renewal form",
                       "contact_name_form",
                       valid_params: { first_name: "Foo", last_name: "Bar" },
                       invalid_params: { first_name: "", last_name: "" },
                       test_attribute: :contact_name

      context "When the transient_registration is a new registration" do
        let(:transient_registration) do
          create(:new_registration, workflow_state: "contact_name_form")
        end

        include_examples "POST form",
                         "contact_name_form",
                         valid_params: { first_name: "Foo", last_name: "Bar" },
                         invalid_params: { first_name: "", last_name: "" }
      end
    end

    describe "GET back_contact_name_forms_path" do
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
                   workflow_state: "contact_name_form")
          end

          context "when the back action is triggered" do
            it "returns a 302 response and redirects to the declare_convictions form" do
              get back_contact_name_forms_path(transient_registration.token)

              expect(response).to have_http_status(302)
              expect(response).to redirect_to(new_declare_convictions_form_path(transient_registration.token))
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
              get back_contact_name_forms_path(transient_registration.token)

              expect(response).to have_http_status(302)
              expect(response).to redirect_to(new_renewal_start_form_path(transient_registration.token))
            end
          end
        end
      end
    end
  end
end
