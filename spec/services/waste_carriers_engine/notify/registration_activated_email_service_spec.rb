# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  module Notify
    RSpec.describe RegistrationActivatedEmailService do
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
              registered_address: "42, Foo Gardens, Baz City, FA1 1KE",
              date_registered: registration.metaData.date_registered.strftime("%e %B %Y"),
              link_to_file: "Hello World"
            }
          }
        end

        before do
          allow(Notifications)
            .to receive(:prepare_upload)
            .and_return("Hello World")

          expect_any_instance_of(Notifications::Client)
            .to receive(:send_email)
            .with(expected_notify_options)
            .and_call_original
        end

        context "a lower tier registration" do
          let(:template_id) { "889fa2f2-f70c-4b5a-bbc8-d94a8abd3990" }
          let(:registration) { create(:registration, :has_required_data, :lower_tier) }
          let(:registration_type) { nil }

          subject do
            VCR.use_cassette("notify_lower_tier_registration_activated_sends_an_email") do
              described_class.run(registration: registration)
            end
          end

          it "sends an email" do
            expect(subject).to be_a(Notifications::Client::ResponseNotification)
            expect(subject.template["id"]).to eq(template_id)
            expect(subject.content["subject"]).to eq("Waste Carrier Registration Complete")
          end
        end

        context "an upper tier registration" do
          let(:template_id) { "fe1e4746-c940-4ace-b111-8be64ee53b35" }
          let(:registration) { create(:registration, :has_required_data, :already_renewed) }
          let(:registration_type) { "carrier, broker and dealer" }

          subject do
            VCR.use_cassette("notify_upper_tier_registration_activated_sends_an_email") do
              described_class.run(registration: registration)
            end
          end

          it "sends an email" do
            expect(subject).to be_a(Notifications::Client::ResponseNotification)
            expect(subject.template["id"]).to eq(template_id)
            expect(subject.content["subject"]).to eq("Waste Carrier Registration Complete")
          end
        end
      end
    end
  end
end
