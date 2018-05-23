require "rails_helper"

RSpec.describe OrderItem, type: :model do
  before do
    allow(Rails.configuration).to receive(:renewal_charge).and_return(100)
    allow(Rails.configuration).to receive(:type_change_charge).and_return(25)
    allow(Rails.configuration).to receive(:card_charge).and_return(10)
  end

  let(:transient_registration) { build(:transient_registration, :has_required_data) }

  describe "new_renewal_item" do
    let(:order_item) { OrderItem.new_renewal_item }

    it "should have a type of 'RENEW'" do
      expect(order_item.type).to eq("RENEW")
    end

    it "should set the correct amount" do
      expect(order_item.amount).to eq(100)
    end

    it "should set the correct description" do
      expect(order_item.description).to eq("Renewal of registration")
    end
  end

  describe "new_type_change_item" do
    let(:order_item) { OrderItem.new_type_change_item }

    it "should have a type of 'CHARGE_ADJUST'" do
      expect(order_item.type).to eq("CHARGE_ADJUST")
    end

    it "should set the correct amount" do
      expect(order_item.amount).to eq(25)
    end

    it "should set the correct description" do
      expect(order_item.description).to eq("Changing carrier type during renewal")
    end
  end

  describe "new_copy_cards_item" do
    let(:order_item) { OrderItem.new_copy_cards_item(3) }

    it "should have a type of 'COPY_CARDS'" do
      expect(order_item.type).to eq("COPY_CARDS")
    end

    it "should set the correct amount" do
      expect(order_item.amount).to eq(30)
    end

    it "should set the correct description" do
      expect(order_item.description).to eq("3x registration cards")
    end
  end
end
