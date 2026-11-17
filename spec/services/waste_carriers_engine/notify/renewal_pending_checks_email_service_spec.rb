# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  module Notify

    RSpec.describe RenewalPendingChecksEmailService do
      let(:template_id) { "d2442022-4f4c-4edd-afc5-aaa0607dabdf" }
      let(:reg_identifier) { registration.reg_identifier }
      let(:contact_email) { "foo@example.com" }
      let(:notifications_client) { Notifications::Client.new(WasteCarriersEngine.configuration.notify_api_key) }
      let(:expected_notify_options) do
        {
          email_address: contact_email,
          template_id: template_id,
          personalisation: {
            reg_identifier: reg_identifier,
            registration_type: "carrier, broker and dealer"
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
            VCR.use_cassette("notify_renewal_pending_checks_sends_an_email") do
              described_class.run(registration: renewing_registration)
            end
          end

          let(:recipient) { renewing_registration.contact_email }

          it "sends an email" do
            expect(run_service).to be_a(Notifications::Client::ResponseNotification)
            expect(run_service.template["id"]).to eq(template_id)
            expect(run_service.content["subject"]).to match(
              /Your application to renew waste carriers registration CBDU\d has been received/
            )
          end

          it_behaves_like "calls notify with reference" do
            let(:send_action) { :send_email }
            let(:reference) { registration.reg_identifier }
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
