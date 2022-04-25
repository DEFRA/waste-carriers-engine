# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "BusinessTypeForms", type: :request do
    include_examples "GET flexible form", "business_type_form"

    describe "POST business_type_form_path" do
      include_examples "POST renewal form",
                       "business_type_form",
                       valid_params: { business_type: "limitedCompany" },
                       invalid_params: { business_type: "foo" },
                       test_attribute: :business_type

      context "When the transient_registration is a new registration" do
        let(:transient_registration) do
          create(:new_registration, workflow_state: "business_type_form")
        end

        include_examples "POST form",
                         "business_type_form",
                         valid_params: { business_type: "limitedCompany" },
                         invalid_params: { business_type: "foo" }

        # When the user starts with one business type then navigates back and changes the type
        context "when the transient_registration already has limitedCompany attributes" do
          before do
            transient_registration.company_no = Faker::Number.number(digits: 8)
            transient_registration.registered_company_name = Faker::Company.name
            transient_registration.temp_use_registered_company_details = "yes"
            transient_registration.save!
          end

          subject { post_form_with_params("business_type_form", transient_registration.token, { business_type: "soleTrader" }) }

          it "removes the limitedCompany attributes" do
            subject
            transient_registration.reload
            expect(transient_registration.company_no).to be_nil
            expect(transient_registration.registered_company_name).to be_nil
            expect(transient_registration.temp_use_registered_company_details).to be_nil
          end
        end
      end
    end

    describe "GET back_business_type_forms_path" do
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
                   workflow_state: "business_type_form")
          end

          context "when the back action is triggered" do
            it "returns a 302 response and redirects to the location form" do
              get back_business_type_forms_path(transient_registration.token)

              expect(response).to have_http_status(302)
              expect(response).to redirect_to(new_location_form_path(transient_registration.token))
            end
          end
        end

        context "when the transient registration is in the wrong state" do
          let(:transient_registration) do
            create(:renewing_registration,
                   :has_required_data,
                   account_email: user.email,
                   workflow_state: "location_form")
          end

          context "when the back action is triggered" do
            it "returns a 302 response and redirects to the correct form for the state" do
              get back_business_type_forms_path(transient_registration.token)

              expect(response).to have_http_status(302)
              expect(response).to redirect_to(new_location_form_path(transient_registration.token))
            end
          end
        end
      end
    end
  end
end
