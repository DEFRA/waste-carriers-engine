# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  module Notify
    RSpec.describe RegistrationActivatedService do
      let(:template_id) { "889fa2f2-f70c-4b5a-bbc8-d94a8abd3990" }

      let(:expected_notify_options) do
        {
          email_address: "foo@example.com",
          template_id: template_id,
          personalisation: {
            reg_identifier: registration.reg_identifier,
            registration_type: "carrier_broker_dealer",
            first_name: "Jane",
            last_name: "Doe",
            phone_number: "03708 506506",
            registered_address: "42, Foo Gardens, Baz City, FA1 1KE",
            date_registered: registration.metaData.date_registered,
            link_to_file: "http://example.com"
          }
        }
      end

      describe ".run" do
        let(:registration) { create(:registration, :has_required_data, :is_active) }
        let(:service) { described_class.run(registration: registration) }

        it "sends an email" do
          VCR.use_cassette("notify_registration_activated_sends_an_email") do
            expect_any_instance_of(Notifications::Client)
              .to receive(:send_email)
              .with(expected_notify_options)
              .and_call_original

            response = service

            expect(response).to be_a(Notifications::Client::ResponseNotification)
            expect(response.template["id"]).to eq(template_id)
            expect(response.content["subject"]).to eq("Waste Carrier Registration Complete")
          end
        end
      end
    end
  end
end
