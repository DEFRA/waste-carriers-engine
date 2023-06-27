# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe AssignSiteDetailsService, type: :service do
    describe "#run" do
      let(:x) { 123_456 }
      let(:y) { 654_321 }
      let(:area) { "Area Name" }
      let(:registration) { create(:registration, :has_required_data) }

      subject(:run_service) { described_class.run(registration_id: registration.id) }

      before do
        # We will replace the factory-generated company address with one of our own for test purposes
        registration.addresses.delete_if { |address| address.address_type == "REGISTERED" }

        allow(DetermineEastingAndNorthingService).to receive(:run)
        allow(DetermineAreaService).to receive(:run)
      end

      context "when address has a postcode and area is not present" do

        before do
          create(:address, :has_required_data, address_type: "REGISTERED", registration: registration)
          allow(DetermineEastingAndNorthingService).to receive(:run).and_return(easting: x, northing: y)
        end

        context "when the service returns an area" do
          before { allow(DetermineAreaService).to receive(:run).and_return(area) }

          it "assigns area" do
            expect { run_service }.to change { registration.reload.company_address.area }.to(area)
          end
        end

        context "when the service does not return an area" do
          before { allow(DetermineAreaService).to receive(:run).and_return(nil) }

          it "does not assign area" do
            expect { run_service }.not_to change { registration.reload.company_address.area }
          end
        end
      end

      context "when address has an area" do
        before { create(:address, :has_required_data, address_type: "REGISTERED", area: area, registration: registration) }

        it "does not change the area" do
          expect { run_service }.not_to change { registration.reload.company_address.area }

          expect(DetermineEastingAndNorthingService).not_to have_received(:run)
          expect(DetermineAreaService).not_to have_received(:run)
        end
      end

      context "when address does not have a postcode" do
        before { create(:address, :has_required_data, address_type: "REGISTERED", postcode: nil, registration: registration) }

        it "does not assign area" do
          expect { run_service }.not_to change { registration.reload.company_address.area }

          expect(DetermineEastingAndNorthingService).not_to have_received(:run)
          expect(DetermineAreaService).not_to have_received(:run)
        end
      end

      context "when address has an overseas registration" do
        let(:registration) { create(:registration, :has_required_overseas_data) }

        before do
          # Replace the factory-generated registered address with one of our own for test purposes
          registration.addresses.delete_if { |address| address.address_type == "REGISTERED" }
          create(:address, :has_required_data, address_type: "REGISTERED", registration: registration)
        end

        it "assigns area as 'Outside England'" do
          expect { run_service }.to change { registration.reload.company_address.area }.to("Outside England")
        end
      end
    end
  end
end
