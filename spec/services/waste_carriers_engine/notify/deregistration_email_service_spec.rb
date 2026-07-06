# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  module Notify

    RSpec.describe DeregistrationEmailService do
      let(:template_id) { "b9926a88-95db-47bd-96d4-0aaae7a322d3" }

      describe ".run" do
        let(:deregistration_link) { "https://a.deregistration.link" }
        let(:expected_notify_options) do
          {
            email_address: registration.contact_email,
            template_id:,
            personalisation: {
              reg_identifier: registration.reg_identifier,
              company_name: registration.company_name,
              first_name: registration.first_name,
              last_name: registration.last_name,
              deregistration_link: deregistration_link
            }
          }
        end
        let(:magic_link_service) { instance_double(DeregistrationMagicLinkService) }
        let(:notifications_client) { instance_double(Notifications::Client) }
        let(:notifications_client_response_notification) do
          instance_double(Notifications::Client::ResponseNotification, content: { "body" => "Email content" })
        end

        subject(:run_service) { described_class.run(registration: registration) }

        before do
          allow(DeregistrationMagicLinkService).to receive(:new).and_return(magic_link_service)
          allow(magic_link_service).to receive(:run).with(registration:).and_return(deregistration_link)
          allow(Notifications::Client).to receive(:new).and_return(notifications_client)
          allow(notifications_client).to receive(:send_email).and_return(notifications_client_response_notification)
          allow(notifications_client_response_notification).to receive(:instance_of?)
            .with(Notifications::Client::ResponseNotification).and_return(true)
        end

        context "with a contact_email" do
          let(:registration) { create(:registration, :has_required_data, :lower_tier) }

          it "generates a link" do
            run_service
            expect(magic_link_service).to have_received(:run)
          end

          it "sends an email" do
            run_service
            expect(notifications_client).to have_received(:send_email).with(expected_notify_options)
          end

          it_behaves_like "can create a communication record", "email"
        end

        context "with no contact_email" do
          let(:registration) { create(:registration, :has_required_data, contact_email: nil) }

          it "does not generate a link" do
            run_service
            expect(magic_link_service).not_to have_received(:run)
          end

          it "does not send an email" do
            run_service
            expect(notifications_client).not_to have_received(:send_email)
          end
        end
      end
    end
  end
end
