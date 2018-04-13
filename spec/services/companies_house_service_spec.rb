require "rails_helper"

RSpec.describe CompaniesHouseService do
  let(:companies_house_service) { CompaniesHouseService.new("09360070") }

  context "when the request times out" do
    it "returns :error" do
      VCR.turned_off do
        host = "https://api.companieshouse.gov.uk/"
        stub_request(:any, /.*#{host}.*/).to_timeout
        expect(companies_house_service.status).to eq(:error)
      end
    end
  end

  context "when the request returns a socket error" do
    it "returns :error" do
      VCR.turned_off do
        host = "https://api.companieshouse.gov.uk/"
        stub_request(:any, /.*#{host}.*/).to_raise(SocketError)
        expect(companies_house_service.status).to eq(:error)
      end
    end
  end
end
