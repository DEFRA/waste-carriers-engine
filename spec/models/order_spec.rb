require "rails_helper"

RSpec.describe Order, type: :model do
  before do
    allow(Rails.configuration).to receive(:renewal_charge).and_return(100)
    allow(Rails.configuration).to receive(:type_change_charge).and_return(25)
    allow(Rails.configuration).to receive(:card_charge).and_return(10)
  end

  let(:transient_registration) { build(:transient_registration, :has_required_data, temp_cards: 0) }

  describe "new_order" do
    let(:order) { Order.new_order(transient_registration) }

    it "should have a valid order_id" do
      Timecop.freeze(Time.new(2018, 1, 1)) do
        expect(order[:order_id]).to eq("1514764800")
      end
    end

    it "should have a matching order_id and order_code" do
      expect(order[:order_id]).to eq(order[:order_code])
    end

    it "should include 1 renewal item" do
      matching_item = order[:order_items].find { |item| item[:type] == "RENEW" }
      expect(matching_item).to_not be_nil
    end

    it "should have the correct total_amount" do
      expect(order.total_amount).to eq(10_000)
    end

    context "when the registration type has not changed" do
      it "should not include a type change item" do
        matching_item = order[:order_items].find { |item| item[:type] == "CHARGE_ADJUST" }
        expect(matching_item).to be_nil
      end
    end

    context "when the registration type has changed" do
      before do
        transient_registration.registration_type = "broker_dealer"
      end

      it "should include a type change item" do
        matching_item = order[:order_items].find { |item| item[:type] == "CHARGE_ADJUST" }
        expect(matching_item).to_not be_nil
      end

      it "should have the correct total_amount" do
        expect(order.total_amount).to eq(12_500)
      end
    end

    context "when there are no copy cards" do
      it "should not include a copy cards item" do
        matching_item = order[:order_items].find { |item| item[:type] == "COPY_CARDS" }
        expect(matching_item).to be_nil
      end
    end

    context "when there are copy cards" do
      before do
        transient_registration.temp_cards = 3
      end

      it "should include a copy cards item" do
        matching_item = order[:order_items].find { |item| item[:type] == "COPY_CARDS" }
        expect(matching_item).to_not be_nil
      end

      it "should have the correct total_amount" do
        expect(order.total_amount).to eq(13_000)
      end
    end
  end
end
