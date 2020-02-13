# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe CertificatePresenter do
    describe "calling root model attributes" do
      let(:registration) { create(:registration, :has_required_data) }

      it "returns the value of the attribute" do
        presenter = CertificatePresenter.new(registration, view)
        expect(presenter.company_name).to eq("Acme Waste")
      end
    end

    describe "#carrier_name" do
      let(:registration) { create(:registration, :has_required_data) }

      context "when the registration business type is 'soleTrader'" do
        it "returns the carrier's name" do
          registration.business_type = "soleTrader"
          presenter = CertificatePresenter.new(registration, view)
          expect(presenter.carrier_name).to eq("Kate Franklin")
        end
      end

      context "when the registration business type is NOT 'sole trader'" do
        it "returns the company name" do
          presenter = CertificatePresenter.new(registration, view)
          expect(presenter.carrier_name).to eq("Acme Waste")
        end
      end
    end

    describe "#complex_organisation_details?" do
      let(:registration) { create(:registration, :has_required_data) }

      test_values = {
        limitedCompany: false,
        soleTrader: true,
        partnership: true
      }
      test_values.each do |business_type, expected|
        context "when the registration business type is '#{business_type}'" do
          it "returns '#{expected}'" do
            registration.business_type = business_type
            presenter = CertificatePresenter.new(registration, view)
            expect(presenter.complex_organisation_details?).to eq(expected)
          end
        end
      end
    end

    describe "#complex_organisation_heading" do
      let(:registration) { create(:registration, :has_required_data) }

      context "when the registration business type is 'partnership'" do
        it "returns 'Partners'" do
          registration.business_type = "partnership"
          presenter = CertificatePresenter.new(registration, view)
          expect(presenter.complex_organisation_heading).to eq("Partners")
        end
      end

      context "when the registration business type is NOT 'partnership'" do
        it "returns a generic title" do
          presenter = CertificatePresenter.new(registration, view)
          expect(presenter.complex_organisation_heading).to eq("Business name (if applicable)")
        end
      end
    end

    describe "#complex_organisation_name" do
      let(:registration) { create(:registration, :has_required_data, :has_mulitiple_key_people) }

      context "when the registration business type is 'partnership'" do
        it "returns a list of the partners names" do
          registration.business_type = "partnership"
          presenter = CertificatePresenter.new(registration, view)
          expect(presenter.complex_organisation_name).to eq("Kate Franklin<br>Ryan Gosling")
        end
      end

      context "when the registration business type is NOT 'partnership'" do
        it "returns the company name" do
          presenter = CertificatePresenter.new(registration, view)
          expect(presenter.complex_organisation_name).to eq("Acme Waste")
        end
      end
    end

    describe "#tier_and_registration_type" do
      context "when the registration is upper tier" do
        let(:registration) { create(:registration, :has_required_data) }

        test_values = {
          carrier_dealer: "An upper tier waste carrier and dealer",
          broker_dealer: "An upper tier waste broker and dealer",
          carrier_broker_dealer: "An upper tier waste carrier, broker and dealer"
        }
        test_values.each do |carrier_type, expected|
          context "and is a '#{carrier_type}'" do
            it "returns '#{expected}'" do
              registration.registration_type = carrier_type
              presenter = CertificatePresenter.new(registration, view)
              expect(presenter.tier_and_registration_type).to eq(expected)
            end
          end
        end
      end

      context "when the registration is lower tier" do
        let(:registration) { create(:registration, :has_required_data, tier: "LOWER") }
        expected_value = "A lower tier waste carrier, broker and dealer"

        it "returns '#{expected_value}'" do
          presenter = CertificatePresenter.new(registration, view)
          expect(presenter.tier_and_registration_type).to eq(expected_value)
        end
      end
    end

    describe "#expires_after_pluralized" do
      let(:registration) { create(:registration, :has_required_data) }

      context "when the config is set to 1 year" do
        before do
          allow(Rails.configuration).to receive(:expires_after).and_return(1)
        end

        it "returns '1 year'" do
          presenter = CertificatePresenter.new(registration, view)
          expect(presenter.expires_after_pluralized).to eq("1 year")
        end
      end

      context "when the config is set to 3 years" do
        before do
          allow(Rails.configuration).to receive(:expires_after).and_return(3)
        end

        it "returns '3 years'" do
          presenter = CertificatePresenter.new(registration, view)
          expect(presenter.expires_after_pluralized).to eq("3 years")
        end
      end
    end

    describe "#list_main_people" do
      let(:registration) { create(:registration, :has_required_data, :has_mulitiple_key_people) }

      it "returns a list of names separated by a <br>" do
        presenter = CertificatePresenter.new(registration, view)
        expect(presenter.list_main_people).to eq("Kate Franklin<br>Ryan Gosling")
      end
    end

    describe "#assisted_digital?" do
      let(:registration) { create(:registration, :has_required_data) }

      context "when the registration is assisted digital" do
        it "returns 'true'" do
          registration.metaData.route = "ASSISTED_DIGITAL"
          presenter = CertificatePresenter.new(registration, view)
          expect(presenter.assisted_digital?).to be true
        end
      end

      context "when the registration is not assisted digital" do
        it "returns 'false'" do
          presenter = CertificatePresenter.new(registration, view)
          expect(presenter.assisted_digital?).to be false
        end
      end
    end
  end
end
