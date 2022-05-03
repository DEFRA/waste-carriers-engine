# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "LocationForms", type: :request do
    include_examples "GET flexible form", "location_form"

    describe "POST location_form_path" do
      include_examples "POST renewal form",
                       "location_form",
                       valid_params: { location: "england" },
                       invalid_params: { location: "foo" },
                       test_attribute: :location

      context "When the transient_registration is a new registration" do
        let(:transient_registration) do
          create(:new_registration, workflow_state: "location_form")
        end

        include_examples "POST form",
                         "location_form",
                         valid_params: { location: "england" },
                         invalid_params: { location: "foo" }

        # When the user starts with a UK company type and then navigates back and changes the location to non-UK
        context "when the transient_registration already has company attributes" do
          let(:company_no) { Faker::Number.number(digits: 8).to_s }
          let(:registered_company_name) { Faker::Company.name }
          let(:temp_use_registered_company_details) { "yes" }

          before do
            transient_registration.company_no = company_no
            transient_registration.registered_company_name = registered_company_name
            transient_registration.temp_use_registered_company_details = temp_use_registered_company_details
            transient_registration.save!
          end

          context "and the location is no longer in the UK" do
            subject { post_form_with_params("location_form", transient_registration.token, { location: "overseas" }) }

            it "removes the company attributes" do
              subject
              transient_registration.reload
              expect(transient_registration.company_no).to be_nil
              expect(transient_registration.registered_company_name).to be_nil
              expect(transient_registration.temp_use_registered_company_details).to be_nil
            end
          end
        end
      end
    end

    describe "GET back_location_forms_path" do
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
                   workflow_state: "location_form")
          end

          context "when the back action is triggered" do
            it "returns a 302 response and redirects to the renewal_start form" do
              get back_location_forms_path(transient_registration[:token])

              expect(response).to have_http_status(302)
              expect(response).to redirect_to(new_renewal_start_form_path(transient_registration[:token]))
            end
          end
        end

        context "when the transient registration is in the wrong state" do
          let(:transient_registration) do
            create(:renewing_registration,
                   :has_required_data,
                   account_email: user.email,
                   workflow_state: "company_name_form")
          end

          context "when the back action is triggered" do
            it "returns a 302 response and redirects to the correct form for the state" do
              get back_location_forms_path(transient_registration[:token])

              expect(response).to have_http_status(302)
              expect(response).to redirect_to(new_company_name_form_path(transient_registration[:token]))
            end
          end
        end
      end
    end
  end
end
