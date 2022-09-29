# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  module Notify

    # TODO: Refactor to remove the use of allow_any_instance_of
    # rubocop:disable RSpec/AnyInstance
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
        context "with a contact_email" do
          before do
            allow_any_instance_of(Notifications::Client)
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
            expect(run_service.content["subject"]).to match(
              /Application received for waste carrier registration CBDU/
            )
          end
        end

        context "with no contact_email" do
          before { registration.contact_email = nil }

          it "does not attempt to send an email" do
            expect_any_instance_of(Notifications::Client).not_to receive(:send_email)

            described_class.run(registration: registration)
          end
        end
      end
    end
    # rubocop:enable RSpec/AnyInstance
  end
end
