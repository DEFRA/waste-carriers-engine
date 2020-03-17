# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe OrderItem, type: :model do
    before do
      allow(Rails.configuration).to receive(:renewal_charge).and_return(10_000)
      allow(Rails.configuration).to receive(:new_registration_charge).and_return(12_000)
      allow(Rails.configuration).to receive(:type_change_charge).and_return(2_500)
      allow(Rails.configuration).to receive(:card_charge).and_return(1_000)
    end

    let(:transient_registration) { build(:renewing_registration, :has_required_data) }

    describe ".new_charge_adjust_item" do
      it "returns an instance of itself of type :charge_adjust" do
        result = described_class.new_charge_adjust_item

        expect(result.type).to eq("CHARGE_ADJUST")
      end
    end

    describe "new_renewal_item" do
      let(:order_item) { described_class.new_renewal_item }

      it "should have a type of 'RENEW'" do
        expect(order_item.type).to eq(described_class::TYPES[:renew])
      end

      it "should set the correct amount" do
        expect(order_item.amount).to eq(10_000)
      end

      it "should set the correct quantity" do
        expect(order_item.quantity).to eq(1)
      end

      it "should set the correct description" do
        expect(order_item.description).to eq("renewal of registration")
      end
    end

    describe "new_registration_item" do
      let(:order_item) { described_class.new_registration_item }

      it "should have a type of 'RENEW'" do
        expect(order_item.type).to eq(described_class::TYPES[:new_registration])
      end

      it "should set the correct amount" do
        expect(order_item.amount).to eq(12_000)
      end

      it "should set the correct quantity" do
        expect(order_item.quantity).to eq(1)
      end

      it "should set the correct description" do
        expect(order_item.description).to eq("Initial Registration")
      end
    end

    describe "new_type_change_item" do
      let(:order_item) { described_class.new_type_change_item }

      it "should have a type of 'EDIT'" do
        expect(order_item.type).to eq(described_class::TYPES[:edit])
      end

      it "should set the correct quantity" do
        expect(order_item.quantity).to eq(1)
      end

      it "should set the correct amount" do
        expect(order_item.amount).to eq(2_500)
      end

      it "should set the correct description" do
        expect(order_item.description).to eq("changing carrier type")
      end
    end

    describe "new_copy_cards_item" do
      let(:cards) { 3 }
      let(:order_item) { described_class.new_copy_cards_item(cards) }

      it "should have a type of 'COPY_CARDS'" do
        expect(order_item.type).to eq(described_class::TYPES[:copy_cards])
      end

      it "should set the correct amount" do
        expect(order_item.amount).to eq(3_000)
      end

      it "should set the correct quantity" do
        expect(order_item.quantity).to eq(3)
      end

      it "should set the correct description" do
        expect(order_item.description).to eq("3 registration cards")
      end

      context "when the number of cards is 1" do
        let(:cards) { 1 }

        it "should set the correct description" do
          expect(order_item.description).to eq("1 registration card")
        end
      end
    end
  end
end
