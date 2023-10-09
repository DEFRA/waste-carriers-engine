# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  module Notify

    # TODO: Refactor to remove the use of allow_any_instance_of
    # rubocop:disable RSpec/AnyInstance
    RSpec.describe RenewalConfirmationEmailService do
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
              date_activated: registration.metaData.date_activated.to_s(:standard),
              link_to_file: "My certificate"
            }
          }
        end

        context "with a contact_email" do
          before do
            allow(Notifications)
              .to receive(:prepare_upload)
              .and_return("My certificate")

            allow_any_instance_of(Notifications::Client)
              .to receive(:send_email)
              .with(expected_notify_options)
              .and_call_original
          end

          context "with an upper tier registration" do
            let(:template_id) { "6d54a9bc-9b62-4d93-a40a-d06d04ed58ca" }
            let(:registration) { create(:registration, :has_required_data, :already_renewed) }
            let(:registration_type) { "carrier, broker and dealer" }

            subject(:run_service) do
              VCR.use_cassette("notify_upper_tier_renewal_confirmation_sends_an_email") do
                described_class.run(registration: registration)
              end
            end

            it "sends an email" do
              expect(run_service).to be_a(Notifications::Client::ResponseNotification)
              expect(run_service.template["id"]).to eq(template_id)
              expect(run_service.content["subject"])
                .to match(/Your waste carriers registration CBDU\d+ has been renewed/)
            end
          end
        end

        context "with no contact_email" do
          let(:registration) { create(:registration, :has_required_data, :already_renewed, contact_email: nil) }

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
