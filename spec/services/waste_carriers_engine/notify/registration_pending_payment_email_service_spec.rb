# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  module Notify

    RSpec.describe RegistrationPendingPaymentEmailService do
      let(:template_id) { "b8b68a4c-adc9-4fe6-86cd-3d5a83822c47" }
      let(:reg_identifier) { registration.reg_identifier }
      let(:notifications_client) { Notifications::Client.new(WasteCarriersEngine.configuration.notify_api_key) }
      let(:expected_notify_options) do
        {
          email_address: "foo@example.com",
          template_id: template_id,
          personalisation: {
            reg_identifier: reg_identifier,
            first_name: "Jane",
            last_name: "Doe",
            sort_code: "60-70-80",
            account_number: "1001 4411",
            payment_due: "100",
            iban: "GB23 NWBK 607080 10014411",
            swiftbic: "NWBK GB2L",
            currency: "Sterling"
          }
        }
      end
      let(:registration) { create(:registration, :has_required_data) }

      before do
        registration.finance_details = build(:finance_details, :has_required_data)
        registration.save
      end

      describe ".run" do
        context "with a contact_email" do
          before do
            allow(notifications_client)
              .to receive(:send_email)
              .with(expected_notify_options)
              .and_call_original
          end

          subject(:run_service) do
            VCR.use_cassette("notify_registration_pending_payment_sends_an_email") do
              described_class.run(registration: registration)
            end
          end

          it_behaves_like "calls notify with reference" do
            let(:send_action) { :send_email }
            let(:reference) { registration.reg_identifier }
          end

          it "sends an email" do
            expect(run_service).to be_a(Notifications::Client::ResponseNotification)
            expect(run_service.template["id"]).to eq(template_id)
            expect(run_service.content["subject"]).to include("Payment needed for waste carrier registration CBDU")
          end

          it_behaves_like "calls notify with reference" do
            let(:send_action) { :send_email }
            let(:reference) { registration.reg_identifier }
          end

          it_behaves_like "can create a communication record", "email"
        end

        context "with no contact_email" do
          before { registration.contact_email = nil }

          it "does not attempt to send an email" do
            allow(notifications_client).to receive(:send_email)

            described_class.run(registration: registration)

            expect(notifications_client).not_to have_received(:send_email)
          end
        end
      end
    end
  end
end
