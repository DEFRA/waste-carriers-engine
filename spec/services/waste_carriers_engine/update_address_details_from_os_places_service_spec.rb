# frozen_string_literal: true

# spec/services/waste_carriers_engine/determine_easting_and_northing_service_spec.rb

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe UpdateAddressDetailsFromOsPlacesService, type: :service do
    subject(:run_service) { described_class.new.run(address:) }

    let(:address) { build(:address) }
    let(:os_places_data) { JSON.parse(file_fixture("os_places_response.json").read) }
    let(:invalid_postcode) { "INVALID" }
    let(:valid_postcode) { "SW1A 1AA" }

    describe "#run" do

      before { address.postcode = postcode }

      context "when given an invalid postcode" do
        let(:postcode) { invalid_postcode }

        before do
          allow(AddressLookupService).to receive(:run).with(invalid_postcode).and_return(
            instance_double(DefraRuby::Address::Response, successful?: false, error: DefraRuby::Address::NoMatchError.new)
          )
        end

        it "does not update the address" do
          expect { run_service }.not_to change { address }
        end
      end

      context "when the postcode lookup service returns an error" do
        let(:postcode) { valid_postcode }

        before do
          allow(AddressLookupService).to receive(:run).with(valid_postcode).and_return(
            instance_double(DefraRuby::Address::Response, successful?: false, error: StandardError.new("An error occurred"))
          )
        end

        it "does not update the address" do
          expect { run_service }.not_to change { address }
        end
      end

      context "when given a valid postcode" do
        let(:postcode) { valid_postcode }

        before do
          allow(AddressLookupService).to receive(:run).with(valid_postcode).and_return(
            instance_double(DefraRuby::Address::Response, successful?: true, results: [os_places_data])
          )

          run_service
        end

        it { expect(address.uprn).to eq 340_116 }
        it { expect(address.address_mode).to eq "address-results" }
        it { expect(address.dependent_locality).to eq "SOUTH BRISTOL" }
        it { expect(address.area).to eq("BRISTOL") }
        it { expect(address.town_city).to eq "BRISTOL" }
        it { expect(address.postcode).to eq "BS1 5AH" }
        it { expect(address.country).to eq "" }
        it { expect(address.local_authority_update_date).to eq "" }
        it { expect(address.easting).to eq(358_205.0) }
        it { expect(address.northing).to eq(172_708.0) }
      end
    end
  end
end
