# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  module Notify

    # TODO: Refactor to remove the use of allow_any_instance_of
    # rubocop:disable RSpec/AnyInstance
    RSpec.describe RegistrationConfirmationEmailService do
      let(:notification_type) { "email" }

      before do
        registration.generate_view_certificate_token!
      end

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
              registered_address: "42\r\nFoo Gardens\r\nBaz City\r\nBS1 5AH",
              date_registered: registration.metaData.date_registered.to_fs(:standard),
              link_to_file: "http://localhost:3002/fo/#{registration.reg_identifier}/certificate?token=#{registration.view_certificate_token}",
              unsubscribe_link: WasteCarriersEngine::UnsubscribeLinkService.run(registration:)
            }
          }
        end

        context "with a contact_email" do
          before do
            allow(Notifications)
              .to receive(:prepare_upload)
              .and_return("Hello World")

            allow_any_instance_of(Notifications::Client)
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

              it "will create a communication record with the expected attributes" do
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

              it "will create a communication record with the expected attributes" do
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
            expect_any_instance_of(Notifications::Client).not_to receive(:send_email)

            described_class.run(registration: registration)
          end
        end
      end
    end
    # rubocop:enable RSpec/AnyInstance
  end
end
