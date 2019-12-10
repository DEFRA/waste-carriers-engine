# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "WasteTypesForms", type: :request do
    include_examples "GET flexible form", "waste_types_form"

    include_examples "POST form",
                     "waste_types_form",
                     valid_params: { only_amf: "yes" },
                     invalid_params: { only_amf: "foo" },
                     test_attribute: :only_amf

    describe "GET back_waste_types_forms_path" do
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
                   workflow_state: "waste_types_form")
          end

          context "when the back action is triggered" do
            it "returns a 302 response" do
              get back_waste_types_forms_path(transient_registration[:token])
              expect(response).to have_http_status(302)
            end

            it "redirects to the service_provided form" do
              get back_waste_types_forms_path(transient_registration[:token])
              expect(response).to redirect_to(new_service_provided_form_path(transient_registration[:token]))
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
              get back_waste_types_forms_path(transient_registration[:token])
              expect(response).to have_http_status(302)
            end

            it "redirects to the correct form for the state" do
              get back_waste_types_forms_path(transient_registration[:token])
              expect(response).to redirect_to(new_renewal_start_form_path(transient_registration[:token]))
            end
          end
        end
      end
    end
  end
end
