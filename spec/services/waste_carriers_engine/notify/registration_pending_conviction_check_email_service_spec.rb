# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  module Notify

    RSpec.describe RegistrationPendingConvictionCheckEmailService do
      let(:template_id) { "e7dbb0d2-feca-4f59-a5e6-576e5051f4e0" }
      let(:registration) { create(:registration, :has_required_data) }
      let(:reg_identifier) { registration.reg_identifier }
      let(:notifications_client) { Notifications::Client.new(WasteCarriersEngine.configuration.notify_api_key) }

      let(:expected_notify_options) do
        {
          email_address: "foo@example.com",
          template_id: template_id,
          personalisation: {
            reg_identifier: reg_identifier,
            first_name: "Jane",
            last_name: "Doe"
          }
        }
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
            VCR.use_cassette("notify_registration_pending_conviction_check_sends_an_email") do
              described_class.run(registration: registration)
            end
          end

          it "sends an email" do
            expect(run_service).to be_a(Notifications::Client::ResponseNotification)
            expect(run_service.template["id"]).to eq(template_id)
            expect(run_service.content["subject"]).to include("Application received for waste carrier registration CBDU")
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
