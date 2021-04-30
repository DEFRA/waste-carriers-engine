# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  module Notify
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
              registered_address: "42\r\nFoo Gardens\r\nBaz City\r\nFA1 1KE",
              date_activated: registration.metaData.date_activated.strftime("%e %B %Y"),
              link_to_file: "My certificate"
            }
          }
        end

        before do
          allow(Notifications)
            .to receive(:prepare_upload)
            .and_return("My certificate")

          expect_any_instance_of(Notifications::Client)
            .to receive(:send_email)
            .with(expected_notify_options)
            .and_call_original
        end

        context "an upper tier registration" do
          let(:template_id) { "6d54a9bc-9b62-4d93-a40a-d06d04ed58ca" }
          let(:registration) { create(:registration, :has_required_data, :already_renewed) }
          let(:registration_type) { "carrier, broker and dealer" }

          subject do
            VCR.use_cassette("notify_upper_tier_renewal_confirmation_sends_an_email") do
              described_class.run(registration: registration)
            end
          end

          it "sends an email" do
            expect(subject).to be_a(Notifications::Client::ResponseNotification)
            expect(subject.template["id"]).to eq(template_id)
            expect(subject.content["subject"])
              .to match(/Your waste carriers registration CBDU\d has been renewed/)
          end
        end
      end
    end
  end
end
