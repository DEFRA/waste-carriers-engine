# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe AddressFinderService do
    let(:address_finder_service) { AddressFinderService.new("BS1 5AH") }

    context "when the response can be parsed as JSON" do
      it "returns the parsed JSON", vcr: true do
        VCR.use_cassette("postcode_valid") do
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

    context "when OS Places returns a bad request error" do
      let(:address_finder_service) { AddressFinderService.new("AA1 1AA") }

      it "returns :not_found", vcr: true do
        VCR.use_cassette("postcode_no_matches") do
          expect(address_finder_service.search_by_postcode).to eq(:not_found)
        end
      end
    end

    context "when the request times out" do
      it "returns :error" do
        VCR.turned_off do
          host = Rails.configuration.os_places_service_url
          stub_request(:any, /.*#{host}.*/).to_timeout
          expect(address_finder_service.search_by_postcode).to eq(:error)
        end
      end
    end

    context "when the request returns an error" do
      it "returns :error" do
        VCR.turned_off do
          host = Rails.configuration.os_places_service_url
          stub_request(:any, /.*#{host}.*/).to_raise(SocketError)
          expect(address_finder_service.search_by_postcode).to eq(:error)
        end
      end
    end
  end
end
