# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe CompaniesHouseService do
    let(:companies_house_service) { CompaniesHouseService.new("09360070") }

    context "when a company_no is for an active company" do
      it "returns :active", vcr: true do
        VCR.use_cassette("company_no_valid") do
          expect(companies_house_service.status).to eq(:active)
        end
      end
    end

    context "when a company_no is not found" do
      let(:companies_house_service) { CompaniesHouseService.new("99999999") }

      it "returns :not_found", vcr: true do
        VCR.use_cassette("company_no_not_found") do
          expect(companies_house_service.status).to eq(:not_found)
        end
      end
    end

    context "when a company_no is inactive" do
      let(:companies_house_service) { CompaniesHouseService.new("07281919") }

      it "returns :inactive", vcr: true do
        VCR.use_cassette("company_no_inactive") do
          expect(companies_house_service.status).to eq(:inactive)
        end
      end
    end

    context "when the request times out" do
      it "returns :error" do
        VCR.turned_off do
          host = "https://api.companieshouse.gov.uk/"
          stub_request(:any, /.*#{host}.*/).to_timeout
          expect(companies_house_service.status).to eq(:error)
        end
      end
    end

    context "when the request returns an error" do
      it "returns :error" do
        VCR.turned_off do
          host = "https://api.companieshouse.gov.uk/"
          stub_request(:any, /.*#{host}.*/).to_raise(SocketError)
          expect(companies_house_service.status).to eq(:error)
        end
      end
    end
  end
end
