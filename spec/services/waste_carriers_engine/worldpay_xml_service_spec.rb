# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe WorldpayXmlService do
    # Test with overseas addresses for maximum coverage
    let(:transient_registration) do
      create(:renewing_registration,
             :has_required_data,
             :has_different_contact_email,
             :has_overseas_addresses,
             :has_finance_details,
             temp_cards: 0)
    end
    let(:order) { transient_registration.finance_details.orders.first }
    let(:current_user) { build(:user) }
    let(:worldpay_xml_service) { WorldpayXmlService.new(transient_registration, order) }

    before do
      # Set a specific reg_identifier so we can match our XML
      transient_registration.reg_identifier = "CBDU9999"

      allow(Rails.configuration).to receive(:worldpay_merchantcode).and_return("MERCHANTCODE")

      # This is generated based on the time, so to avoid any millisecond malarky, let's just stub it
      allow_any_instance_of(Order).to receive(:order_code).and_return("1234567890")
      allow_any_instance_of(Order).to receive(:total_amount).and_return(10_000)
    end

    describe "#build_xml" do
      it "returns correctly-formatted XML" do
        xml = File.read("./spec/fixtures/files/worldpay/request_to_worldpay.xml")
        expect(worldpay_xml_service.build_xml).to eq(xml)
      end

      context "when a receipt email is provided" do
        before { transient_registration.receipt_email = "receipt@example.com" }

        it "includes that instead of the contact email" do
          xml = worldpay_xml_service.build_xml
          expect(xml).to include("receipt@example.com")
          expect(xml).to_not include(transient_registration.contact_email)
        end
      end
    end
  end
end
