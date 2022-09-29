# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "RenewalReceivedPendingWorldpayPaymentForms", type: :request do
    describe "GET new_renewal_received_pending_worldpay_payment_form_path" do
      context "when a valid user is signed in" do
        let(:user) { create(:user) }

        before do
          sign_in(user)
        end

        context "when no renewing registration exists" do
          it "redirects to the invalid page" do
            get new_renewal_received_pending_worldpay_payment_form_path("wibblewobblejellyonaplate")

            expect(response).to redirect_to(page_path("invalid"))
          end
        end

        context "when a valid renewing registration exists" do
          let(:transient_registration) do
            create(
              :renewing_registration,
              :has_unpaid_balance,
              workflow_state: "renewal_received_pending_worldpay_payment_form",
              account_email: user.email
            )
          end

          context "when the workflow_state is correct" do
            it "returns a 200 status and renders the :new template" do
              get new_renewal_received_pending_worldpay_payment_form_path(transient_registration.token)

              expect(response).to have_http_status(:ok)
              expect(response).to render_template(:new)
            end
          end

          context "when the workflow_state is not correct" do
            before do
              transient_registration.update_attributes(workflow_state: "payment_summary_form")
            end

            it "redirects to the correct page" do
              get new_renewal_received_pending_worldpay_payment_form_path(transient_registration.token)
              expect(response).to redirect_to(new_payment_summary_form_path(transient_registration.token))
            end
          end
        end
      end
    end
  end
end
