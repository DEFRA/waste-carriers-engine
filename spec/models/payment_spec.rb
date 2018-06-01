require "rails_helper"

RSpec.describe Payment, type: :model do
  let(:transient_registration) { build(:transient_registration, :has_required_data) }

  describe "new_from_worldpay" do
    let(:order) { Order.new_order(transient_registration) }
    let(:payment) { Payment.new_from_worldpay(order) }

    it "should set the correct order_key" do
      Timecop.freeze(Time.new(2018, 1, 1)) do
        expect(payment[:order_key]).to eq("1514764800")
      end
    end

    it "should set the correct amount" do
      expect(payment[:amount]).to eq(11_000)
    end

    it "should set the correct currency" do
      expect(payment[:currency]).to eq("GBP")
    end

    it "should set the correct payment_type" do
      expect(payment[:payment_type]).to eq("WORLDPAY")
    end
  end
end
