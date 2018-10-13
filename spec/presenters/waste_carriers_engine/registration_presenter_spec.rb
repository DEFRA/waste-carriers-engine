require "rails_helper"

module WasteCarriersEngine
  RSpec.describe RegistrationPresenter do
    describe "calling root model attributes" do
      let(:registration) { create(:registration, :has_required_data) }

      it "returns the value of the attribute" do
        presenter = RegistrationPresenter.new(registration, view)
        expect(presenter.company_name).to eq("Acme Waste")
      end
    end

    describe "#complex_organisation_details?" do
      let(:registration) { create(:registration, :has_required_data) }
      context "when the registration is a limited company" do
        it "returns false" do
          presenter = RegistrationPresenter.new(registration, view)
          expect(presenter.complex_organisation_details?).to be false
        end
      end
      context "when the registration is a sole trader" do
        it "returns true" do
          registration.business_type = "soleTrader"
          presenter = RegistrationPresenter.new(registration, view)
          expect(presenter.complex_organisation_details?).to be true
        end
      end
    end

    describe "#carrier_name" do
      let(:registration) { create(:registration, :has_required_data) }
      context "when the registration is a limited company" do
        it "returns the company name" do
          presenter = RegistrationPresenter.new(registration, view)
          expect(presenter.carrier_name).to eq("Acme Waste")
        end
      end
      context "when the registration is a sole trader" do
        it "returns something else" do
          registration.business_type = "soleTrader"
          presenter = RegistrationPresenter.new(registration, view)
          expect(presenter.carrier_name).to eq("Kate Franklin")
        end
      end
    end

    describe "#tier_and_registration_type" do
      let(:registration) { create(:registration, :has_required_data) }
      context "when the registration is a carrier dealer" do
        it "returns a description including 'carrier and dealer'" do
          registration.registration_type = "carrier_dealer"
          presenter = RegistrationPresenter.new(registration, view)
          expect(presenter.tier_and_registration_type).to eq("An upper tier waste carrier and dealer")
        end
      end
      context "when the registration is a broker dealer" do
        it "returns a description including 'broker and dealer'" do
          registration.registration_type = "broker_dealer"
          presenter = RegistrationPresenter.new(registration, view)
          expect(presenter.tier_and_registration_type).to eq("An upper tier waste broker and dealer")
        end
      end
      context "when the registration is a carrier, broker and dealer" do
        it "returns a description including 'carrier, broker and dealer'" do
          registration.registration_type = "carrier_broker_dealer"
          presenter = RegistrationPresenter.new(registration, view)
          expect(presenter.tier_and_registration_type).to eq("An upper tier waste carrier, broker and dealer")
        end
      end
    end

    describe "#list_main_people" do
      let(:registration) do
        reg = create(:registration, :has_required_data)
        person = build(:key_person, :has_required_data, :main)
        person.first_name = "Ryan"
        person.last_name = "Gosling"
        reg.key_people.push(person)
        reg
      end
      context "when the registration is a limited company" do
        it "returns the company name" do
          presenter = RegistrationPresenter.new(registration, view)
          expect(presenter.list_main_people).to eq("Kate Franklin<br>Ryan Gosling")
        end
      end
    end

    describe "#complex_organisation_title" do
      let(:registration) { create(:registration, :has_required_data) }
      context "when the registration is a partnership" do
        it "returns the 'Partners'" do
          registration.business_type = "partnership"
          presenter = RegistrationPresenter.new(registration, view)
          expect(presenter.complex_organisation_title).to eq("Partners")
        end
      end
      context "when the registration is anything else" do
        it "returns something else" do
          presenter = RegistrationPresenter.new(registration, view)
          expect(presenter.complex_organisation_title).to eq("Business name (if applicable)")
        end
      end
    end

    describe "#complex_organisation_name" do
      let(:registration) do
        reg = create(:registration, :has_required_data)
        person = build(:key_person, :has_required_data, :main)
        person.first_name = "Ryan"
        person.last_name = "Gosling"
        reg.key_people.push(person)
        reg
      end

      context "when the registration is a partnership" do
        it "returns the 'Partners' as the name" do
          registration.business_type = "partnership"
          presenter = RegistrationPresenter.new(registration, view)
          expect(presenter.complex_organisation_name).to eq("Kate Franklin<br>Ryan Gosling")
        end
      end
      context "when the registration is anything else" do
        it "returns something the company name" do
          presenter = RegistrationPresenter.new(registration, view)
          expect(presenter.complex_organisation_name).to eq("Acme Waste")
        end
      end
    end

    describe "#assisted_digital?" do
      let(:registration) { create(:registration, :has_required_data) }
      context "when the registration is assisted digital" do
        it "returns the 'Partners'" do
          registration.metaData.route = "ASSISTED_DIGITAL"
          presenter = RegistrationPresenter.new(registration, view)
          expect(presenter.assisted_digital?).to be true
        end
      end
      context "when the registration is not assisted digital" do
        it "returns something else" do
          presenter = RegistrationPresenter.new(registration, view)
          expect(presenter.assisted_digital?).to be false
        end
      end
    end
  end
end
