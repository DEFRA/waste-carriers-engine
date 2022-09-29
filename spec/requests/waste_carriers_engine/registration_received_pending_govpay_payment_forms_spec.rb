# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "RegistrationReceivedPendingGovpayPaymentForm", type: :request do
    describe "GET new_registration_received_pending_govpay_payment_form_path" do
      context "when no new registration exists" do
        it "redirects to the invalid page" do
          get new_registration_received_pending_govpay_payment_form_path("wibblewobblejellyonaplate")

          expect(response).to redirect_to(page_path("invalid"))
        end
      end

      context "when a valid new registration exists" do
        let(:transient_registration) do
          create(
            :new_registration,
            :has_required_data,
            workflow_state: "registration_received_pending_govpay_payment_form"
          )
        end

        context "when the workflow_state is correct" do
          it "returns a 200 status, renders the :new template, creates a new registration and deletes the transient registration" do
            reg_identifier = transient_registration.reg_identifier
            new_registrations_count = WasteCarriersEngine::NewRegistration.count

            get new_registration_received_pending_govpay_payment_form_path(transient_registration.token)

            registration = WasteCarriersEngine::Registration.find_by(reg_identifier: reg_identifier)

            expect(response).to have_http_status(:ok)
            expect(response).to render_template(:new)
            expect(registration).to be_valid
            expect(WasteCarriersEngine::NewRegistration.count).to eq(new_registrations_count - 1)
          end
        end

        context "when the workflow_state is not correct" do
          before do
            transient_registration.update_attributes(workflow_state: "payment_summary_form")
          end

          it "redirects to the correct page and does not creates a new registration nor delete the transient object" do
            new_registrations_count = WasteCarriersEngine::NewRegistration.count

            get new_registration_received_pending_govpay_payment_form_path(transient_registration.token)

            registration_scope = WasteCarriersEngine::Registration.where(reg_identifier: transient_registration.reg_identifier)

            expect(response).to redirect_to(new_payment_summary_form_path(transient_registration.token))
            expect(WasteCarriersEngine::NewRegistration.count).to eq(new_registrations_count)
            expect(registration_scope).to be_empty
          end
        end

        context "when the registration completion service fails" do
          let(:the_error) { StandardError.new("Oops!") }

          before do
            allow(RegistrationCompletionService)
              .to receive(:run)
              .with(transient_registration)
              .and_raise(the_error)

            # Airbrake may receive notifications other than the specific one used in the spec below
            allow(Airbrake).to receive(:notify)
          end

          it "logs the exception" do
            get new_registration_received_pending_govpay_payment_form_path(transient_registration.token)

            expect(Airbrake)
              .to have_received(:notify)
              .with(the_error, { reg_identifier: transient_registration.reg_identifier })
          rescue ActionView::Template::Error
            # Capture the exception raised in the view
          end
        end
      end
    end
  end
end
