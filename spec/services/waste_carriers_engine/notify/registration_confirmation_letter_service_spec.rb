# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  module Notify

    # TODO: Refactor to remove the use of allow_any_instance_of
    # rubocop:disable RSpec/AnyInstance
    RSpec.describe RegistrationConfirmationLetterService do

      context "with an upper tier registration" do
        describe ".run" do
          let(:registration) { create(:registration, :has_required_data, expires_on: 1.year.from_now) }
          let(:template_id) { "06bfc531-6a39-42ec-8466-eba1041fb61b" }

          let(:company_name) { "Acme Waste" }
          let(:registered_company_name) { "Zenith Limited" }
          let(:presentation_name) { "#{registered_company_name} trading as #{company_name}" }
          let(:expected_company_name) { company_name }
          let(:company_name_regex) { /Name of registered carrier[^\w]*#{expected_company_name}\W/ }
          let(:expected_notify_options) do
            {
              template_id: template_id,
              reference: registration.reg_identifier,
              personalisation: {
                contact_name: "Jane Doe",
                registration_type: "carrier, broker and dealer",
                reg_identifier: registration.reg_identifier,
                company_name: expected_company_name,
                registered_address: "42, Foo Gardens, Baz City, BS1 5AH",
                phone_number: "03708 506506",
                date_registered: registration.metaData.date_registered.to_fs(:standard),
                expiry_date: registration.expires_on.in_time_zone("London").to_date.to_s(:standard),
                address_line_1: "Jane Doe",
                address_line_2: "42",
                address_line_3: "Foo Gardens",
                address_line_4: "Baz City",
                address_line_5: "BS1 5AH",
                certificate_creation_date: Date.today.to_s(:standard)
              }
            }
          end

          let(:cassette_name) { "notify_upper_tier_ad_confirmation_letter_business_name" }

          subject(:run_service) do
            VCR.use_cassette(cassette_name) do
              described_class.run(registration: registration)
            end
          end

          before do
            allow_any_instance_of(Notifications::Client)
              .to receive(:send_letter)
              .with(expected_notify_options)
              .and_call_original
          end

          it "sends a letter" do
            expect(run_service).to be_a(Notifications::Client::ResponseNotification)
            expect(run_service.template["id"]).to eq(template_id)
            expect(run_service.reference).to match(/CBDU*/)
            expect(run_service.content["subject"]).to eq(
              "You are now registered as an upper tier waste carrier, broker and dealer"
            )
          end

          context "without a registered company name" do
            let(:expected_company_name) { company_name }
            let(:cassette_name) { "notify_upper_tier_ad_confirmation_letter_business_name" }

            it "includes only the business name" do
              expect(run_service.content["body"]).to match(company_name_regex)
            end
          end

          context "with a registered company name" do
            before do
              registration.registered_company_name = registered_company_name
            end

            context "without a business name" do
              let(:expected_company_name) { registered_company_name }
              let(:cassette_name) { "notify_upper_tier_ad_confirmation_letter_registered_name" }

              before do
                registration.company_name = nil
              end

              it "includes only the business name" do
                expect(run_service.content["body"]).to match(company_name_regex)
              end
            end

            context "with a business name" do
              let(:expected_company_name) { "#{registered_company_name} trading as #{company_name}" }
              let(:cassette_name) { "notify_upper_tier_ad_confirmation_letter_registered_and_business_name" }

              it "includes the presentation name" do
                expect(run_service.content["body"]).to match(company_name_regex)
              end
            end
          end
        end
      end

      context "with a lower tier registration" do
        describe ".run" do
          let(:registration) { create(:registration, :has_required_data, :lower_tier) }
          let(:template_id) { "e144cc0c-8903-434f-97a0-c798fcd35beb" }

          let(:expected_notify_options) do
            {
              template_id: template_id,
              reference: registration.reg_identifier,
              personalisation: {
                contact_name: "Jane Doe",
                reg_identifier: registration.reg_identifier,
                company_name: "Acme Waste",
                registered_address: "42, Foo Gardens, Baz City, BS1 5AH",
                phone_number: "03708 506506",
                date_registered: registration.metaData.date_registered.to_fs(:standard),
                address_line_1: "Jane Doe",
                address_line_2: "42",
                address_line_3: "Foo Gardens",
                address_line_4: "Baz City",
                address_line_5: "BS1 5AH",
                certificate_creation_date: Date.today.to_s(:standard)
              }
            }
          end

          subject(:run_service) do
            VCR.use_cassette("notify_lower_tier_ad_confirmation_letter") do
              described_class.run(registration: registration)
            end
          end

          before do
            allow_any_instance_of(Notifications::Client)
              .to receive(:send_letter)
              .with(expected_notify_options)
              .and_call_original
          end

          it "sends a letter" do
            expect(run_service).to be_a(Notifications::Client::ResponseNotification)
            expect(run_service.template["id"]).to eq(template_id)
            expect(run_service.reference).to match(/CBDL*/)
            expect(run_service.content["subject"]).to eq(
              "You are now registered as a lower tier waste carrier, broker and dealer"
            )
          end
        end
      end
    end
    # rubocop:enable RSpec/AnyInstance
  end
end
