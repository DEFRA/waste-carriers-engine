# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  module Notify

    RSpec.describe RegistrationConfirmationEmailService do
      let(:notification_type) { "email" }
      let(:notifications_client) { Notifications::Client.new(WasteCarriersEngine.configuration.notify_api_key) }

      before do
        registration.generate_view_certificate_token!
        allow(Notifications::Client).to receive(:new).and_return(notifications_client)
      end

      describe ".run" do
        let(:expected_notify_options) do
          {
            email_address: "foo@example.com",
            template_id: template_id,
            reference: registration.regIdentifier,
            personalisation: {
              reg_identifier: registration.reg_identifier,
              registration_type: registration_type,
              first_name: "Jane",
              last_name: "Doe",
              phone_number: "03708 506506",
              registered_address: "42\r\nFoo Gardens\r\nBaz City\r\nBS1 5AH",
              date_registered: registration.metaData.date_registered.to_fs(:standard),
              link_to_file: "http://localhost:3002/fo/#{registration.reg_identifier}/certificate?token=#{registration.view_certificate_token}",
              unsubscribe_link: WasteCarriersEngine::UnsubscribeLinkService.run(registration:)
            }
          }
        end

        context "with a contact_email" do
          before do
            allow(notifications_client)
              .to receive(:send_email)
              .with(expected_notify_options)
              .and_call_original
          end

          context "with a lower tier registration" do
            let(:template_id) { "591d1a44-9c0a-43a5-a76f-235e67df27d8" }
            let(:registration) { create(:registration, :has_required_data, :lower_tier) }
            let(:registration_type) { nil }

            subject(:run_service) do
              VCR.use_cassette("notify_lower_tier_registration_confirmation_sends_an_email") do
                described_class.run(registration: registration)
              end
            end

            it_behaves_like "calls notify with reference" do
              let(:send_action) { :send_email }
              let(:reference) { registration.regIdentifier }
            end

            it "sends an email" do
              expect(run_service).to be_a(Notifications::Client::ResponseNotification)
              expect(run_service.template["id"]).to eq(template_id)
              expect(run_service.content["subject"]).to eq("Waste Carrier Registration Complete")
            end

            describe "creating a communication record" do
              let(:time_sent) { Time.now.utc }
              let(:expected_communication_record_attrs) do
                {
                  notify_template_id: described_class::LOWER_TIER_TEMPLATE_ID,
                  notification_type: notification_type,
                  comms_label: described_class::LOWER_TIER_COMMS_LABEL,
                  sent_at: time_sent,
                  sent_to: registration.contact_email
                }
              end

              it "creates a communication record with the expected attributes" do
                Timecop.freeze(time_sent) do
                  expect { run_service }.to change { registration.communication_records.count }.by(1)
                  expect(registration.communication_records.last[:notify_template_id]).to eq(expected_communication_record_attrs[:notify_template_id])
                  expect(registration.communication_records.last[:notification_type]).to eq(expected_communication_record_attrs[:notification_type])
                  expect(registration.communication_records.last[:comms_label]).to eq(expected_communication_record_attrs[:comms_label])
                  expect(registration.communication_records.last[:sent_at]).to eq(expected_communication_record_attrs[:sent_at])
                  expect(registration.communication_records.last[:sent_to]).to eq(expected_communication_record_attrs[:sent_to])
                end
              end
            end
          end

          context "with an upper tier registration" do
            let(:template_id) { "603840fe-de9e-4824-9715-d975b88ff438" }
            let(:registration) { create(:registration, :has_required_data, :already_renewed) }
            let(:registration_type) { "carrier, broker and dealer" }

            subject(:run_service) do
              VCR.use_cassette("notify_upper_tier_registration_confirmation_sends_an_email") do
                described_class.run(registration: registration)
              end
            end

            it_behaves_like "calls notify with reference" do
              let(:send_action) { :send_email }
              let(:reference) { registration.regIdentifier }
            end

            it "sends an email" do
              expect(run_service).to be_a(Notifications::Client::ResponseNotification)
              expect(run_service.template["id"]).to eq(template_id)
              expect(run_service.content["subject"]).to eq("Waste Carrier Registration Complete")
            end

            describe "creating a communication record" do
              let(:time_sent) { Time.now.utc }
              let(:expected_communication_record_attrs) do
                {
                  notify_template_id: described_class::UPPER_TIER_TEMPLATE_ID,
                  notification_type: notification_type,
                  comms_label: described_class::UPPER_TIER_COMMS_LABEL,
                  sent_at: time_sent,
                  sent_to: registration.contact_email
                }
              end

              it "creates a communication record with the expected attributes" do
                Timecop.freeze(time_sent) do
                  expect { run_service }.to change { registration.communication_records.count }.by(1)
                  expect(registration.communication_records.last[:notify_template_id]).to eq(expected_communication_record_attrs[:notify_template_id])
                  expect(registration.communication_records.last[:notification_type]).to eq(expected_communication_record_attrs[:notification_type])
                  expect(registration.communication_records.last[:comms_label]).to eq(expected_communication_record_attrs[:comms_label])
                  expect(registration.communication_records.last[:sent_at]).to eq(expected_communication_record_attrs[:sent_at])
                  expect(registration.communication_records.last[:sent_to]).to eq(expected_communication_record_attrs[:sent_to])
                end
              end
            end
          end
        end

        context "with no contact_email" do
          let(:registration) { create(:registration, :has_required_data, contact_email: nil) }

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
