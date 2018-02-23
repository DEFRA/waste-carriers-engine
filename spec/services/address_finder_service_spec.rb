require "rails_helper"

RSpec.describe AddressFinderService do
  let(:address_finder_service) { AddressFinderService.new("BS1 5AH") }

  context "when the response can be parsed as JSON" do
    it "returns the parsed JSON" do
      VCR.use_cassette("company_postcode_form_valid_postcode") do
        expect(address_finder_service.search_by_postcode.first["postcode"]).to include("BS1 5AH")
      end
    end
  end

  context "when the response cannot be parsed as JSON" do
    before do
      allow_any_instance_of(RestClient::Request).to receive(:execute).and_return("foo")
    end

    it "returns :error" do
      expect(address_finder_service.search_by_postcode).to eq(:error)
    end
  end

  context "When OS Places returns a bad request error" do
    let(:address_finder_service) { AddressFinderService.new("AA1 1AA") }

    it "returns :not_found" do
      VCR.use_cassette("company_postcode_form_no_matches_postcode") do
        expect(address_finder_service.search_by_postcode).to eq(:not_found)
      end
    end
  end
end
