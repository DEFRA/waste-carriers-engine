# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "CbdTypeForms", type: :request do
    include_examples "GET flexible form", "cbd_type_form"

    describe "POST cbd_type_form_path" do
      include_examples "POST renewal form",
                       "cbd_type_form",
                       valid_params: { registration_type: "broker_dealer" },
                       invalid_params: { registration_type: "foo" },
                       test_attribute: :registration_type

      context "When the transient_registration is a new registration" do
        let(:transient_registration) do
          create(:new_registration, workflow_state: "cbd_type_form")
        end

        include_examples "POST form",
                         "cbd_type_form",
                         valid_params: { registration_type: "broker_dealer" },
                         invalid_params: { registration_type: "foo" }
      end
    end

    describe "GET back_cbd_type_forms_path" do
      context "when a valid user is signed in" do
        let(:user) { create(:user) }
        before(:each) do
          sign_in(user)
        end

        context "when the back action is triggered" do

          context "for a new registration" do
            context "when a valid transient registration exists" do
              let(:transient_registration) do
                create(:new_registration,
                       :has_required_data,
                       account_email: user.email,
                       temp_check_your_tier: temp_check_your_tier,
                       workflow_state: "cbd_type_form")
              end

              context "when the answer to check your tier is upper" do
                let(:temp_check_your_tier) { "upper" }

                it "returns a 302 response and redirects to the check_your_tier form" do
                  get back_cbd_type_forms_path(transient_registration.token)

                  expect(response).to have_http_status(302)
                  expect(response).to redirect_to(new_check_your_tier_form_path(transient_registration.token))
                end
              end

              context "when the answer to check your tier is not upper" do
                let(:temp_check_your_tier) { "unknown" }

                it "returns a 302 response and redirects to the your_tier form" do
                  get back_cbd_type_forms_path(transient_registration.token)

                  expect(response).to have_http_status(302)
                  expect(response).to redirect_to(new_your_tier_form_path(transient_registration.token))
                end
              end
            end
          end

          context "for a renewing registration" do
            context "when a valid transient registration exists" do
              let(:transient_registration) do
                create(:renewing_registration,
                       :has_required_data,
                       account_email: user.email,
                       location: location,
                       workflow_state: "cbd_type_form")
              end

              context "when the business is not based overseas" do
                let(:location) { "england" }

                it "returns a 302 response and redirects to the business_type form" do
                  get back_cbd_type_forms_path(transient_registration.token)

                  expect(response).to have_http_status(302)
                  expect(response).to redirect_to(new_business_type_form_path(transient_registration.token))
                end
              end

              context "when the business is based overseas" do
                let(:location) { "overseas" }

                it "returns a 302 response and redirects to the location_tier form" do
                  get back_cbd_type_forms_path(transient_registration.token)

                  expect(response).to have_http_status(302)
                  expect(response).to redirect_to(new_location_form_path(transient_registration.token))
                end
              end
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
              get back_cbd_type_forms_path(transient_registration.token)

              expect(response).to have_http_status(302)
              expect(response).to redirect_to(new_renewal_start_form_path(transient_registration.token))
            end
          end
        end
      end
    end
  end
end
