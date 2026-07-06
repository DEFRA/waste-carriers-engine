# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  module Notify

    RSpec.describe DeregistrationConfirmationEmailService do
      let(:template_id) { "012a872c-2e79-4efb-a84e-5ce2bf26d0bf" }

      describe ".run" do
        let(:expected_notify_options) do
          {
            email_address: registration.contact_email,
            template_id: template_id,
            personalisation: {
              reg_identifier: registration.reg_identifier,
              first_name: registration.first_name,
              last_name: registration.last_name
            }
          }
        end
        let(:run_service) { described_class.run(registration: registration) }
        let(:notifications_client) { instance_double(Notifications::Client) }
        let(:notifications_client_response_notification) do
          instance_double(Notifications::Client::ResponseNotification, content: { "body" => "Email content" })
        end

        before do
          allow(Notifications::Client).to receive(:new).and_return(notifications_client)
          allow(notifications_client).to receive(:send_email).and_return(notifications_client_response_notification)
          allow(notifications_client_response_notification).to receive(:instance_of?)
            .with(Notifications::Client::ResponseNotification).and_return(true)
        end

        context "with a contact_email" do
          let(:registration) { create(:registration, :has_required_data, :lower_tier) }

          it "sends an email" do
            run_service
            expect(notifications_client).to have_received(:send_email).with(expected_notify_options)
          end

          it_behaves_like "can create a communication record", "email"
        end
      end
    end
  end
end
