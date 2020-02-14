# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe CertificatePresenter do
    subject { described_class.new(registration, view) }

    let(:business_type) { "limitedCompany" }
    let(:company_name) { "Acme Waste" }
    let(:registration_type) { "carrier_broker_dealer" }

    let(:person_a) { double(:key_person, first_name: "Kate", last_name: "Franklin", person_type: "KEY") }
    let(:person_b) { double(:key_person, first_name: "Ryan", last_name: "Gosling", person_type: "KEY") }
    let(:main_people) { [person_a, person_b] }

    let(:route) { "DIGITAL" }
    let(:metaData) do
      double(:metaData,
             route: route)
    end

    let(:lower_tier) { false }
    let(:upper_tier) { true }

    let(:registration) do
      double(:registration,
             business_type: business_type,
             company_name: company_name,
             registrationType: registration_type,
             main_people: main_people,
             metaData: metaData,
             lower_tier?: lower_tier,
             upper_tier?: upper_tier)
    end

    describe "calling root model attributes" do
      it "returns the value of the attribute" do
        expect(subject.company_name).to eq(company_name)
      end
    end

    describe "#carrier_name" do
      context "when the registration business type is 'soleTrader'" do
        let(:business_type) { "soleTrader" }
        let(:main_people) { [person_a] }

        it "returns the carrier's name" do
          expect(subject.carrier_name).to eq("#{person_a.first_name} #{person_a.last_name}")
        end
      end

      context "when the registration business type is NOT 'sole trader'" do
        it "returns the company name" do
          expect(subject.carrier_name).to eq(company_name)
        end
      end
    end

    describe "#complex_organisation_details?" do
      test_values = {
        limitedCompany: false,
        soleTrader: true,
        partnership: true
      }
      test_values.each do |type, expected|
        context "when the registration business type is '#{type}'" do
          let(:business_type) { type.to_s }

          it "returns '#{expected}'" do
            expect(subject.complex_organisation_details?).to eq(expected)
          end
        end
      end
    end

    describe "#complex_organisation_heading" do
      context "when the registration business type is 'partnership'" do
        let(:business_type) { "partnership" }

        it "returns 'Partners'" do
          expect(subject.complex_organisation_heading).to eq("Partners")
        end
      end

      context "when the registration business type is NOT 'partnership'" do
        it "returns a generic title" do
          expect(subject.complex_organisation_heading).to eq("Business name (if applicable)")
        end
      end
    end

    describe "#complex_organisation_name" do
      context "when the registration business type is 'partnership'" do
        let(:business_type) { "partnership" }

        it "returns a list of the partners names" do
          expected_list = "#{person_a.first_name} #{person_a.last_name}<br>#{person_b.first_name} #{person_b.last_name}"
          expect(subject.complex_organisation_name).to eq(expected_list)
        end
      end

      context "when the registration business type is NOT 'partnership'" do
        it "returns the company name" do
          expect(subject.complex_organisation_name).to eq(company_name)
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
          context "and is a '#{type}'" do
            let(:registration_type) { type }

            it "returns '#{expected}'" do
              expect(subject.tier_and_registration_type).to eq(expected)
            end
          end
        end
      end

      context "when the registration is lower tier" do
        let(:lower_tier) { true }
        let(:upper_tier) { false }

        expected = "A lower tier waste carrier, broker and dealer"

        it "returns 'expected'" do
          expect(subject.tier_and_registration_type).to eq(expected)
        end
      end
    end

    describe "#list_main_people" do
      it "returns a list of names separated by a <br>" do
        expect(subject.list_main_people).to eq("Kate Franklin<br>Ryan Gosling")
      end
    end

    describe "#assisted_digital?" do
      context "when the registration is assisted digital" do
        let(:route) { "ASSISTED_DIGITAL" }

        it "returns 'true'" do
          expect(subject.assisted_digital?).to be true
        end
      end

      context "when the registration is not assisted digital" do
        it "returns 'false'" do
          expect(subject.assisted_digital?).to be false
        end
      end
    end

    describe "#renewal_message" do
      context "when the registration is lower tier" do
        let(:lower_tier) { true }
        let(:upper_tier) { false }

        it "returns the correct message" do
          expect(subject.renewal_message).to eq("Your registration will last indefinitely so does not need to be renewed but you must update your registration details if they change, within 28 days of the change.")
        end
      end

      context "when the registration is upper tier" do
        context "when the config is set to 1 year" do
          before do
            allow(Rails.configuration).to receive(:expires_after).and_return(1)
          end

          it "returns '1 year'" do
            expect(subject.renewal_message).to eq("Your registration will last 1 year and will need to be renewed after this period. If any of your details change, you must notify us within 28 days of the change.")
          end
        end

        context "when the config is set to 3 years" do
          before do
            allow(Rails.configuration).to receive(:expires_after).and_return(3)
          end

          it "returns '3 years'" do
            expect(subject.renewal_message).to eq("Your registration will last 3 years and will need to be renewed after this period. If any of your details change, you must notify us within 28 days of the change.")
          end
        end
      end
    end
  end
end
