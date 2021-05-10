# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  module Notify
    RSpec.describe RegistrationConfirmationLetterService do
      before do
        # Make sure it's a real postcode for Notify validation purposes
        allow_any_instance_of(WasteCarriersEngine::Address).to receive(:postcode).and_return("BS1 1AA")
      end

      context "upper tier" do
        let(:registration) { create(:registration, :has_required_data, expires_on: 1.year.from_now) }
        let(:template_id) { "92817aa7-6289-4837-a033-96d287644cb3" }

        describe ".run" do
          let(:expected_notify_options) do
            {
              template_id: template_id,
              personalisation: {
                contact_name: "Jane Doe",
                registration_type: "carrier, broker and dealer",
                reg_identifier: registration.reg_identifier,
                company_name: "Acme Waste",
                registered_address: "42, Foo Gardens, Baz City, BS1 1AA",
                phone_number: "03708 506506",
                date_registered: registration.metaData.date_registered.strftime("%e %B %Y"),
                expiry_date: registration.expires_on.in_time_zone("London").to_date.strftime("%e %B %Y"),
                address_line_1: "Jane Doe",
                address_line_2: "42",
                address_line_3: "Foo Gardens",
                address_line_4: "Baz City",
                address_line_5: "BS1 1AA"
              }
            }
          end

          subject do
            VCR.use_cassette("notify_upper_tier_ad_confirmation_letter") do
              described_class.run(registration: registration)
            end
          end

          context "with an AD email_address" do
            before do
              registration.contact_email = WasteCarriersEngine.configuration.assisted_digital_email

              expect_any_instance_of(Notifications::Client)
                .to receive(:send_letter)
                .with(expected_notify_options)
                .and_call_original
            end

            it "sends a letter" do
              expect(subject).to be_a(Notifications::Client::ResponseNotification)
              expect(subject.template["id"]).to eq(template_id)
              expect(subject.content["subject"]).to eq(
                "You are now registered as an upper tier waste carrier, broker and dealer"
              )
            end
          end

          xcontext "with an invalid email_address" do
            before { registration.contact_email = "foo@example.com" }

            it "raises an AssistedDigitalLetterError" do
              expect { subject }.to raise_error(Exceptions::AssistedDigitalLetterError)
            end
          end
        end

        context "lower tier" do
          it "eventually sends lower tier confirmation letters (#1409)"
        end
      end
    end
  end
end
