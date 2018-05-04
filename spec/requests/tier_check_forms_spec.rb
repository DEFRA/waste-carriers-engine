require "rails_helper"
require "support/shared_examples/request_get_locked_in_form"

RSpec.describe "TierCheckForms", type: :request do
  include_examples "GET locked-in form", form = "tier_check_form"

  include_examples "POST form",
                   form = "tier_check_form",
                   valid_params = { temp_tier_check: "true" },
                   invalid_params = { temp_tier_check: "foo" },
                   test_attribute = :temp_tier_check,
                   expected_value = true

  describe "GET back_tier_check_forms_path" do
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
                 workflow_state: "tier_check_form")
        end

        context "when the back action is triggered" do
          it "returns a 302 response" do
            get back_tier_check_forms_path(transient_registration[:reg_identifier])
            expect(response).to have_http_status(302)
          end

          it "redirects to the business_type form" do
            get back_tier_check_forms_path(transient_registration[:reg_identifier])
            expect(response).to redirect_to(new_business_type_form_path(transient_registration[:reg_identifier]))
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
            get back_tier_check_forms_path(transient_registration[:reg_identifier])
            expect(response).to have_http_status(302)
          end

          it "redirects to the correct form for the state" do
            get back_tier_check_forms_path(transient_registration[:reg_identifier])
            expect(response).to redirect_to(new_renewal_start_form_path(transient_registration[:reg_identifier]))
          end
        end
      end
    end
  end
end
