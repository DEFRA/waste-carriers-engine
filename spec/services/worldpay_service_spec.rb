require "rails_helper"

RSpec.describe WorldpayService do
  # Test with overseas addresses for maximum coverage
  let(:transient_registration) do
    create(:transient_registration,
           :has_required_data,
           :has_overseas_addresses)
  end

  # Set a specific reg_identifier so we can match our XML
  before { transient_registration.reg_identifier = "CBDU9999" }
  let(:worldpay_service) { WorldpayService.new(transient_registration) }

  describe "@xml" do
    it "returns valid xml" do
      xml = File.read("./spec/fixtures/files/request_to_worldpay.xml")
      expect(worldpay_service.instance_variable_get(:@xml)).to eq(xml)
    end
  end
end
