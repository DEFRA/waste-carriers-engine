# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  module Notify

    RSpec.describe CertificateRenewalEmailService do
      let(:notification_type) { "email" }

      describe ".run" do
        let(:expected_notify_options) do
          {
            email_address: "foo@example.com",
            template_id: template_id,
            personalisation: {
              reg_identifier: registration.reg_identifier,
              registration_type: registration_type,
              first_name: "Jane",
              last_name: "Doe",
              phone_number: "03708 506506",
              registered_address: "42, Foo Gardens, Baz City, BS1 5AH",
              date_registered: registration.metaData.date_registered.to_fs(:standard),
              link_to_file: "http://localhost:3002/fo/#{registration.reg_identifier}/certificate?token=#{registration.view_certificate_token}"
            }
          }
        end
        let(:notifications_client) { instance_double(Notifications::Client) }
        let(:notifications_client_response_notification) { instance_double(Notifications::Client::ResponseNotification) }

        subject(:run_service) { described_class.run(registration: registration) }

        before do
          allow(Notifications::Client).to receive(:new).and_return(notifications_client)
          allow(notifications_client).to receive(:send_email).and_return(notifications_client_response_notification)
          allow(notifications_client_response_notification).to receive(:instance_of?)
            .with(Notifications::Client::ResponseNotification).and_return(true)
          registration.generate_view_certificate_token!
        end

        context "with a contact_email" do

          let(:template_id) { "2eae1dbd-08c1-4602-a4d2-e4481a1acc97" }
          let(:registration) { create(:registration, :has_required_data, :already_renewed) }
          let(:registration_type) { "carrier, broker and dealer" }

          it "sends an email" do
            run_service
            expect(notifications_client).to have_received(:send_email).with(expected_notify_options)
          end

          it_behaves_like "can create a communication record", "email"
        end

        context "with no contact_email" do
          let(:registration) { create(:registration, :has_required_data, contact_email: nil) }

          it "does not send an email" do
            run_service
            expect(notifications_client).not_to have_received(:send_email)
          end
        end
      end
    end
  end
end
