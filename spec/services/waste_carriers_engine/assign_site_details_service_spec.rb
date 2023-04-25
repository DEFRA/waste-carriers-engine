require 'rails_helper'

require 'rails_helper'

module WasteCarriersEngine
  RSpec.describe AssignSiteDetailsService, type: :service do
    describe '#run' do
      let(:x) { 123456 }
      let(:y) { 654321 }
      let(:area) { 'Area Name' }

      context 'when address has a postcode and area is not present' do
        let(:address) { build(:address, :has_required_data) }

        before do
          allow(DetermineEastingAndNorthingService).to receive(:run).and_return(easting: x, northing: y)
          allow(DetermineAreaService).to receive(:run).and_return(area)
        end

        it 'assigns area' do
          described_class.run(address: address)
          expect(address.area).to eq(area)
        end
      end

      context 'when address has an area' do
        let(:address) { build(:address, :has_required_data, area: area) }

        it 'does not change the area' do
          expect(DetermineEastingAndNorthingService).not_to receive(:run)
          expect(DetermineAreaService).not_to receive(:run)

          described_class.run(address: address)

          expect(address.area).to eq(area)
        end
      end

      context 'when address does not have a postcode' do
        let(:address) { build(:address, :has_required_data, postcode: nil) }

        it 'does not assign area' do
          expect(DetermineEastingAndNorthingService).not_to receive(:run)
          expect(DetermineAreaService).not_to receive(:run)

          described_class.run(address: address)

          expect(address.area).to be_nil
        end
      end
    end
  end
end
