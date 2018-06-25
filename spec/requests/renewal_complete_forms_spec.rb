require "rails_helper"

RSpec.describe "RenewalCompleteForms", type: :request do
  describe "GET new_renewal_complete_form_path" do
    context "when a valid user is signed in" do
      let(:user) { create(:user) }
      before(:each) do
        sign_in(user)
      end

      context "when no renewal is in progress" do
        let(:registration) do
          create(:registration,
                 :has_required_data,
                 :expires_soon,
                 account_email: user.email)
        end

        it "redirects to the renewal_start_form" do
          get new_renewal_complete_form_path(registration.reg_identifier)
          expect(response).to redirect_to(new_renewal_start_form_path(registration.reg_identifier))
        end

        it "does not renew the registration" do
          old_expires_on = registration.reload.expires_on
          get new_renewal_complete_form_path(registration.reg_identifier)
          expect(registration.reload.expires_on).to eq(old_expires_on)
        end
      end

      context "when a renewal is in progress" do
        let(:transient_registration) do
          create(:transient_registration,
                 :has_required_data,
                 :has_addresses,
                 :has_key_people,
                 workflow_state: "renewal_complete_form",
                 account_email: user.email)
        end

        context "when the workflow_state is correct" do
          it "loads the page" do
            get new_renewal_complete_form_path(transient_registration.reg_identifier)
            expect(response).to have_http_status(200)
          end

          it "renews the registration" do
            registration = Registration.where(reg_identifier: transient_registration.reg_identifier).first
            old_expires_on = registration.expires_on
            get new_renewal_complete_form_path(transient_registration.reg_identifier)
            expect(registration.reload.expires_on).to_not eq(old_expires_on)
          end
        end

        context "when the workflow_state is not correct" do
          before do
            transient_registration.update_attributes(workflow_state: "payment_summary_form")
          end

          it "redirects to the correct page" do
            get new_renewal_complete_form_path(transient_registration.reg_identifier)
            expect(response).to redirect_to(new_payment_summary_form_path(transient_registration.reg_identifier))
          end

          it "does not renew the registration" do
            registration = Registration.where(reg_identifier: transient_registration.reg_identifier).first
            old_expires_on = registration.expires_on
            get new_renewal_complete_form_path(transient_registration.reg_identifier)
            expect(registration.reload.expires_on).to eq(old_expires_on)
          end
        end
      end
    end
  end
end
