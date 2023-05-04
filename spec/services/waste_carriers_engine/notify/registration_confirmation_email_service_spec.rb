# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  module Notify

    # TODO: Refactor to remove the use of allow_any_instance_of
    # rubocop:disable RSpec/AnyInstance
    RSpec.describe RegistrationConfirmationEmailService do
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
              date_registered: registration.metaData.date_registered.strftime("%e %B %Y"),
              link_to_file: "Hello World",
              certificate_creation_date: Date.today.strftime("%e %B %Y")
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
            let(:template_id) { "8d1fb650-93ef-4260-aa08-0b703bbe5609" }
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
          end

          context "with an upper tier registration" do
            let(:template_id) { "4526496c-1ae0-4dc6-a564-c7007b76c164" }
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
