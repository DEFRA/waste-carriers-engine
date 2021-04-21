# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  module Notify
    RSpec.describe RegistrationPendingConvictionCheckEmailService do
      let(:template_id) { "e7dbb0d2-feca-4f59-a5e6-576e5051f4e0" }
      let(:registration) { create(:registration, :has_required_data) }
      let(:reg_identifier) { registration.reg_identifier }

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
        before do
          expect_any_instance_of(Notifications::Client)
            .to receive(:send_email)
            .with(expected_notify_options)
            .and_call_original
        end

        subject do
          VCR.use_cassette("notify_registration_pending_conviction_check_sends_an_email") do
            described_class.run(registration: registration)
          end
        end

        it "sends an email" do
          expect(subject).to be_a(Notifications::Client::ResponseNotification)
          expect(subject.template["id"]).to eq(template_id)
          expect(subject.content["subject"]).to eq(
            "Application received for waste carrier registration #{reg_identifier}")
        end
      end
    end
  end
end
