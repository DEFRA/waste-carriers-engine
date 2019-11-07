# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "OtherBusinessesForms", type: :request do
    include_examples "GET flexible form", "other_businesses_form"

    include_examples "POST form",
                     "other_businesses_form",
                     valid_params: { other_businesses: "yes" },
                     invalid_params: { other_businesses: "foo" },
                     test_attribute: :other_businesses

    describe "GET back_other_businesses_forms_path" do
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
                   workflow_state: "other_businesses_form")
          end

          context "when the back action is triggered" do
            it "returns a 302 response" do
              get back_other_businesses_forms_path(transient_registration[:reg_identifier])
              expect(response).to have_http_status(302)
            end

            it "redirects to the tier_check form" do
              get back_other_businesses_forms_path(transient_registration[:reg_identifier])
              expect(response).to redirect_to(new_tier_check_form_path(transient_registration[:reg_identifier]))
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
              get back_other_businesses_forms_path(transient_registration[:reg_identifier])
              expect(response).to have_http_status(302)
            end

            it "redirects to the correct form for the state" do
              get back_other_businesses_forms_path(transient_registration[:reg_identifier])
              expect(response).to redirect_to(new_renewal_start_form_path(transient_registration[:reg_identifier]))
            end
          end
        end
      end
    end
  end
end
