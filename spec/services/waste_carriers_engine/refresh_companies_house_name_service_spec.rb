# frozen_string_literal: true

require "rails_helper"
require "defra_ruby/companies_house"

RSpec.describe WasteCarriersEngine::RefreshCompaniesHouseNameService do

  subject(:run_service) { described_class.run(reg_identifier: reg_identifier) }

  let(:new_registered_name) { Faker::Company.name }
  let(:registration) { create(:registration, :has_required_data, registered_company_name: old_registered_name) }
  let(:reg_identifier) { registration.reg_identifier }
  let(:companies_house_name) { new_registered_name }
  let(:companies_house_api) { instance_double(DefraRuby::CompaniesHouse::API) }
  let(:companies_house_api_reponse) do
    {
      company_name: companies_house_name
    }
  end

  before do
    allow(DefraRuby::CompaniesHouse::API).to receive(:new).and_return(companies_house_api)
    allow(companies_house_api).to receive(:run).and_return(companies_house_api_reponse)
  end

  context "with no previous companies house name" do
    let(:old_registered_name) { nil }

    it "stores the companies house name" do
      expect { run_service }.to change { registration_data(registration).registered_company_name }
        .from(nil)
        .to(new_registered_name)
    end
  end

  context "with an existing registered company name" do
    let(:old_registered_name) { Faker::Company.name }

    context "when the new company name is the same as the old one" do
      let(:new_registered_name) { old_registered_name }

      it "does not change the companies house name" do
        expect { run_service }.not_to change { registration_data(registration).registered_company_name }
      end
    end

    context "when the new company name is different to the old one" do
      it "updates the registered company name" do
        expect { run_service }
          .to change { registration_data(registration).registered_company_name }
          .from(old_registered_name)
          .to(new_registered_name)
      end
    end
  end
end

def registration_data(registration)
  WasteCarriersEngine::Registration.find_by(reg_identifier: registration.reg_identifier)
end
