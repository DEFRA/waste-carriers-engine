# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  module Notify

    RSpec.describe RenewalPendingPaymentEmailService do
      let(:template_id) { "25a54b31-cdb0-4139-9ffe-50add03d572e" }
      let(:reg_identifier) { registration.reg_identifier }
      let(:contact_email) { "foo@example.com" }
      let(:notifications_client) { Notifications::Client.new(WasteCarriersEngine.configuration.notify_api_key) }
      let(:expected_notify_options) do
        {
          email_address: "foo@example.com",
          template_id: template_id,
          personalisation: {
            reg_identifier: reg_identifier,
            first_name: renewing_registration.first_name,
            last_name: renewing_registration.last_name,
            sort_code: "60-70-80",
            account_number: "1001 4411",
            payment_due: "135.25",
            iban: "GB23 NWBK 607080 10014411",
            swiftbic: "NWBK GB2L",
            currency: "Sterling"
          }
        }
      end

      let(:renewing_registration) { create(:renewing_registration, :has_required_data, :has_finance_details, contact_email: contact_email) }
      let(:registration) { renewing_registration.registration }

      describe ".run" do
        context "with a contact_email" do
          before do
            allow(notifications_client)
              .to receive(:send_email)
              .with(expected_notify_options)
              .and_call_original
          end

          subject(:run_service) do
            VCR.use_cassette("notify_renewal_pending_payment_sends_an_email") do
              described_class.run(registration: renewing_registration)
            end
          end

          it "sends an email" do
            expect(run_service).to be_a(Notifications::Client::ResponseNotification)
            expect(run_service.template["id"]).to eq(template_id)
            expect(run_service.content["subject"]).to include("Payment needed for waste carrier registration CBDU")
          end

          it_behaves_like "calls notify with reference" do
            let(:send_action) { :send_email }
            let(:reference) { registration.regIdentifier }
          end

          it_behaves_like "can create a communication record", "email"
        end

        context "with no contact_email" do
          before { renewing_registration.contact_email = nil }

          it "does not attempt to send an email" do
            allow(notifications_client).to receive(:send_email)

            described_class.run(registration: renewing_registration)

            expect(notifications_client).not_to have_received(:send_email)
          end
        end
      end
    end
  end
end
