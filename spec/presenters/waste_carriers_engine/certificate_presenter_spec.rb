# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe CertificatePresenter do
    subject(:presenter) { described_class.new(registration, view) }

    include_context "with a sample registration with defaults", :registration do
      let(:registration_type) { "carrier_broker_dealer" }
    end
    let(:registration) { resource }

    describe "calling root model attributes" do
      it "returns the value of the attribute" do
        expect(presenter.company_name).to eq(company_name)
      end
    end

    describe "#entity_display_name" do
      let(:registered_company_name) { Faker::Company.name }

      it "returns legal_entity_name trading as company_name" do
        expect(presenter.entity_display_name).to eq("#{registered_company_name} trading as #{company_name}")
      end
    end

    describe "#complex_organisation_details?" do
      context "when the registration is lower tier" do
        let(:tier) { "LOWER" }

        it "returns 'false'" do
          expect(presenter.complex_organisation_details?).to be false
        end
      end

      context "when the registration is upper tier" do
        test_values = {
          limitedCompany: false,
          soleTrader: true,
          partnership: true
        }
        test_values.each do |type, expected|
          context "when the registration business type is '#{type}'" do
            let(:business_type) { type.to_s }

            it "returns '#{expected}'" do
              expect(presenter.complex_organisation_details?).to eq(expected)
            end
          end
        end
      end
    end

    describe "#complex_organisation_heading" do
      context "when the registration is lower tier" do
        let(:tier) { "LOWER" }

        it "returns a generic title" do
          expect(presenter.complex_organisation_heading).to eq("Business name (if applicable)")
        end
      end

      context "when the registration is upper tier" do
        context "when the registration business type is 'partnership'" do
          let(:business_type) { "partnership" }

          it "returns 'Partners'" do
            expect(presenter.complex_organisation_heading).to eq("Partners")
          end
        end

        context "when the registration business type is NOT 'partnership'" do
          it "returns a generic title" do
            expect(presenter.complex_organisation_heading).to eq("Business name (if applicable)")
          end
        end
      end
    end

    describe "#complex_organisation_name" do
      context "when the registration business type is 'partnership'" do
        let(:business_type) { "partnership" }

        it "returns a list of the partners names" do
          expected_list = "#{person_a.first_name} #{person_a.last_name}<br>#{person_b.first_name} #{person_b.last_name}"
          expect(presenter.complex_organisation_name).to eq(expected_list)
        end
      end

      context "when the registration business type is NOT 'partnership'" do
        it "returns the company name" do
          expect(presenter.complex_organisation_name).to eq(company_name)
        end
      end
    end

    describe "#tier_and_registration_type" do
      context "when the registration is upper tier" do
        test_values = {
          carrier_dealer: "An upper tier waste carrier and dealer",
          broker_dealer: "An upper tier waste broker and dealer",
          carrier_broker_dealer: "An upper tier waste carrier, broker and dealer"
        }
        test_values.each do |type, expected|
          context "when is a '#{type}'" do
            let(:registration_type) { type }

            it "returns '#{expected}'" do
              expect(presenter.tier_and_registration_type).to eq(expected)
            end
          end
        end
      end

      context "when the registration is lower tier" do
        let(:tier) { "LOWER" }

        expected = "A lower tier waste carrier, broker and dealer"

        it "returns 'expected'" do
          expect(presenter.tier_and_registration_type).to eq(expected)
        end
      end
    end

    describe "#list_main_people" do
      it "returns a list of names separated by a <br>" do
        expect(presenter.send(:list_main_people)).to eq(
          "#{person_a.first_name} #{person_a.last_name}<br>#{person_b.first_name} #{person_b.last_name}"
        )
      end
    end

    describe "#assisted_digital?" do
      context "when the registration is assisted digital" do
        before { allow(Rails.configuration).to receive(:metadata_route).and_return("ASSISTED_DIGITAL") }

        it "returns 'true'" do
          expect(presenter.assisted_digital?).to be true
        end
      end

      context "when the registration is not assisted digital" do
        it "returns 'false'" do
          expect(presenter.assisted_digital?).to be false
        end
      end
    end

    describe "#certificate_creation_date" do
      it "returns today's date in the expected format" do
        expect(presenter.certificate_creation_date).to eq Date.today.to_s(:standard)
      end
    end

    describe "#certificate_version" do
      context "when the certificate version number is set" do
        before { registration.metaData.update(certificate_version: 2) }

        it "returns certificate version number" do
          expect(presenter.certificate_version).to eq(2)
        end
      end

      context "when the certificate version number is not set" do
        it "returns 1" do
          expect(presenter.certificate_version).to eq(1)
        end
      end
    end

    describe "#renewal_message" do
      context "when the registration is lower tier" do
        let(:tier) { "LOWER" }

        it "returns the correct message" do
          expect(presenter.renewal_message).to eq("Your registration will last indefinitely so does not need to be renewed but you must update your registration details if they change, within 28 days of the change.")
        end
      end

      context "when the registration is upper tier" do
        context "when the config is set to 1 year" do
          before do
            allow(Rails.configuration).to receive(:expires_after).and_return(1)
          end

          it "returns '1 year'" do
            expect(presenter.renewal_message).to eq("Your registration will last 1 year and will need to be renewed after this period. If any of your details change, you must notify us within 28 days of the change.")
          end
        end

        context "when the config is set to 3 years" do
          before do
            allow(Rails.configuration).to receive(:expires_after).and_return(3)
          end

          it "returns '3 years'" do
            expect(presenter.renewal_message).to eq("Your registration will last 3 years and will need to be renewed after this period. If any of your details change, you must notify us within 28 days of the change.")
          end
        end
      end
    end
  end
end
