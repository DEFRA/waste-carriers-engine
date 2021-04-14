# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  module Notify
    RSpec.describe RegistrationActivatedService do
      describe ".run" do
        let(:registration) { create(:registration, :has_required_data, :is_active) }
        let(:service) { described_class.run(registration: registration) }

        it "sends an email" do
          VCR.use_cassette("notify_registration_activated_sends_an_email") do
            expect_any_instance_of(Notifications::Client).to receive(:send_email).and_call_original

            response = service

            expect(response).to be_a(Notifications::Client::ResponseNotification)
            expect(response.template["id"]).to eq("889fa2f2-f70c-4b5a-bbc8-d94a8abd3990")
            expect(response.content["subject"]).to eq("Waste Carrier Registration Complete")
          end
        end
      end
    end
  end
end
