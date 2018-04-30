require "rails_helper"

RSpec.describe "RenewalReceivedForms", type: :request do
  describe "GET new_renewal_received_path" do
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
                 workflow_state: "renewal_received_form")
        end

        it "returns a success response" do
          get new_renewal_received_form_path(transient_registration[:reg_identifier])
          expect(response).to have_http_status(200)
        end
      end

      context "when a transient registration is in a different state" do
        let(:transient_registration) do
          create(:transient_registration,
                 :has_required_data,
                 account_email: user.email,
                 workflow_state: "renewal_start_form")
        end

        it "redirects to the form for the current state" do
          get new_renewal_received_form_path(transient_registration[:reg_identifier])
          expect(response).to redirect_to(new_renewal_start_form_path(transient_registration[:reg_identifier]))
        end
      end
    end
  end
end
