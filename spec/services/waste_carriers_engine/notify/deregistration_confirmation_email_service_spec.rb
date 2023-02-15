# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  module Notify

    RSpec.describe DeregistrationConfirmationEmailService do
      describe ".run" do
        let(:expected_notify_options) do
          {
            email_address: registration.contact_email,
            template_id: "012a872c-2e79-4efb-a84e-5ce2bf26d0bf",
            personalisation: {
              reg_identifier: registration.reg_identifier,
              first_name: registration.first_name,
              last_name: registration.last_name
            }
          }
        end
        let(:notifications_client) { instance_double(Notifications::Client) }

        before do
          allow(Notifications::Client).to receive(:new).and_return(notifications_client)
          allow(notifications_client).to receive(:send_email)

          described_class.run(registration: registration)
        end

        context "with a contact_email" do
          let(:registration) { create(:registration, :has_required_data, :lower_tier) }

          it "sends an email" do
            expect(notifications_client).to have_received(:send_email).with(expected_notify_options)
          end
        end
      end
    end
  end
end
