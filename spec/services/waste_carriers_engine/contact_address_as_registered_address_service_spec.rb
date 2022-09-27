# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe ContactAddressAsRegisteredAddressService do
    describe "run" do
      let!(:transient_registration) do
        create(:transient_registration, :has_registered_address)
      end

      let(:contact_address) do
        transient_registration.reload.contact_address
      end

      let(:registered_address) do
        transient_registration.registered_address
      end

      before { described_class.run(transient_registration) }

      it "reuses the registered_address as the contact_address" do
        expect(contact_address.house_number).to eq(registered_address.house_number)
        expect(contact_address.address_line1).to eq(registered_address.address_line1)
        expect(contact_address.town_city).to eq(registered_address.town_city)
        expect(contact_address.postcode).to eq(registered_address.postcode)
      end

      it "assigns the POSTAL addressType to the new contact_address" do
        expect(contact_address.address_type).to eq("POSTAL")
      end
    end

    describe "run (when there is no registered_address)" do
      let!(:transient_registration) do
        create(:transient_registration)
      end

      before { described_class.run(transient_registration) }

      it "does not try to clone a blank registered_address" do
        expect(transient_registration.reload.contact_address).to be_blank
      end
    end
  end
end
