require "rails_helper"

RSpec.describe WorldpayXmlService do
  # Test with overseas addresses for maximum coverage
  let(:transient_registration) do
    create(:transient_registration,
           :has_required_data,
           :has_overseas_addresses)
  end
  let(:worldpay_xml_service) { WorldpayXmlService.new(transient_registration) }

  before do
    # Set a specific reg_identifier so we can match our XML
    transient_registration.reg_identifier = "CBDU9999"

    allow(Rails.configuration).to receive(:worldpay_merchantcode).and_return("MERCHANTCODE")
  end

  describe "build_xml" do
    it "returns correctly-formatted XML" do
      xml = File.read("./spec/fixtures/files/request_to_worldpay.xml")
      expect(worldpay_xml_service.build_xml).to eq(xml)
    end
  end
end
