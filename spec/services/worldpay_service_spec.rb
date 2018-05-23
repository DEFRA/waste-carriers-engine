require "rails_helper"

RSpec.describe WorldpayService do
  let(:worldpay_service) do
    WorldpayService.new(create(:transient_registration,
                               :has_required_data,
                               :has_addresses))
  end

  describe "@xml" do
    it "returns valid xml" do
      xml = File.read("./spec/fixtures/files/request_to_worldpay.xml")
      expect(worldpay_service.instance_variable_get(:@xml)).to eq(xml)
    end
  end
end
