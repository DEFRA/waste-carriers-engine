# frozen_string_literal: true

require "rails_helper"
require "defra_ruby/companies_house"

module WasteCarriersEngine
  RSpec.describe "RenewalInformationForms" do
    let(:defra_ruby_companies_api) { instance_double(DefraRuby::CompaniesHouse::API) }
    let(:companies_house_api_response) do
      {
        company_status: "active"
      }
    end

    before do
      allow(DefraRuby::CompaniesHouse::API).to receive(:new).and_return(defra_ruby_companies_api)
      allow(defra_ruby_companies_api).to receive(:run).and_return(companies_house_api_response)
    end

    it_behaves_like "GET flexible form", "renewal_information_form"

    it_behaves_like "POST without params form", "renewal_information_form"
  end
end
