# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  module Notify

    RSpec.describe DeregistrationEmailService do
      describe ".run" do
        let(:deregistration_link) { "https://a.deregistration.link" }
        let(:expected_notify_options) do
          {
            email_address: registration.contact_email,
            template_id: "0001e85a-7a09-4d6d-8988-ffb6fe4e2fd2",
            personalisation: {
              company_name: registration.company_name,
              first_name: registration.first_name,
              last_name: registration.last_name,
              deregistration_link: deregistration_link
            }
          }
        end
        let(:magic_link_service) { instance_double(DeregistrationMagicLinkService) }
        let(:notifications_client) { instance_double(Notifications::Client) }

        before do
          allow(DeregistrationMagicLinkService).to receive(:new).and_return(magic_link_service)
          allow(magic_link_service).to receive(:run).with(registration:).and_return(deregistration_link)
          allow(Notifications::Client).to receive(:new).and_return(notifications_client)
          allow(notifications_client).to receive(:send_email)

          described_class.run(registration: registration)
        end

        context "with a contact_email" do
          let(:registration) { create(:registration, :has_required_data, :lower_tier) }

          it "generates a link" do
            expect(magic_link_service).to have_received(:run)
          end

          it "sends an email" do
            expect(notifications_client).to have_received(:send_email).with(expected_notify_options)
          end
        end

        context "with no contact_email" do
          let(:registration) { create(:registration, :has_required_data, contact_email: nil) }

          it "does not generate a link" do
            expect(magic_link_service).not_to have_received(:run)
          end

          it "does not send an email" do
            expect(notifications_client).not_to have_received(:send_email)
          end
        end
      end
    end
  end
end
