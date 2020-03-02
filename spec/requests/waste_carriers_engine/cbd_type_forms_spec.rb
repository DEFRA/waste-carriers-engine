# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "CbdTypeForms", type: :request do
    include_examples "GET flexible form", "cbd_type_form"

    include_examples "POST renewal form",
                     "cbd_type_form",
                     valid_params: { registration_type: "broker_dealer" },
                     invalid_params: { registration_type: "foo" },
                     test_attribute: :registration_type

    describe "GET back_cbd_type_forms_path" do
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
                   workflow_state: "cbd_type_form")
          end

          context "when the back action is triggered" do
            it "returns a 302 response" do
              get back_cbd_type_forms_path(transient_registration.token)
              expect(response).to have_http_status(302)
            end

            context "when the business doesn't carry waste for other businesses or households" do
              before(:each) { transient_registration.update_attributes(other_businesses: "no") }

              it "redirects to the construction_demolition form" do
                get back_cbd_type_forms_path(transient_registration.token)
                expect(response).to redirect_to(new_construction_demolition_form_path(transient_registration.token))
              end
            end

            context "when the business carries waste produced by its customers" do
              before(:each) do
                transient_registration.update_attributes(other_businesses: "yes",
                                                         is_main_service: "yes")
              end

              it "redirects to the waste_types form" do
                get back_cbd_type_forms_path(transient_registration.token)
                expect(response).to redirect_to(new_waste_types_form_path(transient_registration.token))
              end
            end

            context "when the business carries waste for other businesses but produces that waste" do
              before(:each) do
                transient_registration.update_attributes(other_businesses: "yes",
                                                         is_main_service: "no")
              end

              it "redirects to the construction_demolition form" do
                get back_cbd_type_forms_path(transient_registration.token)
                expect(response).to redirect_to(new_construction_demolition_form_path(transient_registration.token))
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
            it "returns a 302 response" do
              get back_cbd_type_forms_path(transient_registration.token)
              expect(response).to have_http_status(302)
            end

            it "redirects to the correct form for the state" do
              get back_cbd_type_forms_path(transient_registration.token)
              expect(response).to redirect_to(new_renewal_start_form_path(transient_registration.token))
            end
          end
        end
      end
    end
  end
end
