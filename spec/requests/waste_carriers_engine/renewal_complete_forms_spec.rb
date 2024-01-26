# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "RenewalCompleteForms" do
    describe "GET new_renewal_complete_form_path" do

      context "when no renewing registration exists" do
        it "redirects to the invalid page" do
          get new_renewal_complete_form_path("wibblewobblejellyonaplate")
          expect(response).to redirect_to(page_path("invalid"))
        end
      end

      context "when a valid renewing registration exists" do
        let(:transient_registration) do
          create(:renewing_registration,
                 :has_required_data,
                 :has_addresses,
                 :has_key_people,
                 workflow_state: "renewal_complete_form")
        end

        context "when the workflow_state is correct" do
          it "returns a 200 response and renews the registration" do
            registration = Registration.where(reg_identifier: transient_registration.reg_identifier).first
            old_expires_on = registration.expires_on

            get new_renewal_complete_form_path(transient_registration.token)

            expect(response).to have_http_status(:ok)
            expect(registration.reload.expires_on).not_to eq(old_expires_on)
          end

          it "records the expected page view" do
            get new_renewal_complete_form_path(transient_registration.token)

            expect(Analytics::UserJourney.where(token: transient_registration.token).count).to eq 1
            expect(Analytics::UserJourney.last.page_views.last.page).to eq "renewal_complete_form"
          end
        end

        context "when the workflow_state is not correct" do
          before do
            transient_registration.update_attributes(workflow_state: "payment_summary_form")
          end

          it "redirects to the correct page and does not renew the registration" do
            registration = Registration.where(reg_identifier: transient_registration.reg_identifier).first
            old_expires_on = registration.expires_on

            get new_renewal_complete_form_path(transient_registration.token)

            expect(response).to redirect_to(new_payment_summary_form_path(transient_registration.token))
            expect(registration.reload.expires_on).to eq(old_expires_on)
          end
        end
      end
    end
  end
end
