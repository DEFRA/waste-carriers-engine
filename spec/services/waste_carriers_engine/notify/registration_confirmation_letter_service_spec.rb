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
          let(:template_id) { "92817aa7-6289-4837-a033-96d287644cb3" }

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
                registered_address: "42, Foo Gardens, Baz City, FA1 1KE",
                phone_number: "03708 506506",
                date_registered: registration.metaData.date_registered.strftime("%e %B %Y"),
                expiry_date: registration.expires_on.in_time_zone("London").to_date.strftime("%e %B %Y"),
                address_line_1: "Jane Doe",
                address_line_2: "42",
                address_line_3: "Foo Gardens",
                address_line_4: "Baz City",
                address_line_5: "FA1 1KE"
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
          let(:template_id) { "0ad5d154-9e44-4da7-8c1b-b4b14d1057cd" }

          let(:expected_notify_options) do
            {
              template_id: template_id,
              reference: registration.reg_identifier,
              personalisation: {
                contact_name: "Jane Doe",
                reg_identifier: registration.reg_identifier,
                company_name: "Acme Waste",
                registered_address: "42, Foo Gardens, Baz City, FA1 1KE",
                phone_number: "03708 506506",
                date_registered: registration.metaData.date_registered.strftime("%e %B %Y"),
                address_line_1: "Jane Doe",
                address_line_2: "42",
                address_line_3: "Foo Gardens",
                address_line_4: "Baz City",
                address_line_5: "FA1 1KE"
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
