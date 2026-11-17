# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  module Notify

    RSpec.describe RenewalConfirmationEmailService do

      before do
        registration.generate_view_certificate_token!
      end

      describe ".run" do
        let(:notifications_client) { Notifications::Client.new(WasteCarriersEngine.configuration.notify_api_key) }
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
              date_activated: registration.metaData.date_activated.to_fs(:standard),
              link_to_file: "http://localhost:3002/fo/#{registration.reg_identifier}/certificate?token=#{registration.view_certificate_token}"
            }
          }
        end

        context "with a contact_email" do
          before do
            allow(Notifications)
              .to receive(:prepare_upload)
              .and_return("My certificate")

            allow(notifications_client)
              .to receive(:send_email)
              .with(expected_notify_options)
              .and_call_original
          end

          context "with an upper tier registration" do
            let(:template_id) { "738cb684-9c89-4041-b3b3-66bc983922cc" }
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

            it_behaves_like "calls notify with reference" do
              let(:send_action) { :send_email }
              let(:reference) { registration.reg_identifier }
            end

            it_behaves_like "can create a communication record", "email"
          end
        end

        context "with no contact_email" do
          let(:registration) { create(:registration, :has_required_data, :already_renewed, contact_email: nil) }

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
