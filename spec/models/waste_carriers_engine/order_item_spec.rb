# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe OrderItem do
    before do
      allow(Rails.configuration).to receive_messages(renewal_charge: 10_000, new_registration_charge: 12_000, type_change_charge: 2_500, card_charge: 1_000)
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

      it "has a type of 'RENEW'" do
        expect(order_item.type).to eq(described_class::TYPES[:renew])
      end

      it "sets the correct amount" do
        expect(order_item.amount).to eq(10_000)
      end

      it "sets the correct quantity" do
        expect(order_item.quantity).to eq(1)
      end

      it "sets the correct description" do
        expect(order_item.description).to eq("renewal of registration")
      end
    end

    describe "new_registration_item" do
      let(:order_item) { described_class.new_registration_item }

      it "has a type of 'RENEW'" do
        expect(order_item.type).to eq(described_class::TYPES[:new_registration])
      end

      it "sets the correct amount" do
        expect(order_item.amount).to eq(12_000)
      end

      it "sets the correct quantity" do
        expect(order_item.quantity).to eq(1)
      end

      it "sets the correct description" do
        expect(order_item.description).to eq("initial registration")
      end
    end

    describe "new_type_change_item" do
      let(:order_item) { described_class.new_type_change_item }

      it "has a type of 'EDIT'" do
        expect(order_item.type).to eq(described_class::TYPES[:edit])
      end

      it "sets the correct quantity" do
        expect(order_item.quantity).to eq(1)
      end

      it "sets the correct amount" do
        expect(order_item.amount).to eq(2_500)
      end

      it "sets the correct description" do
        expect(order_item.description).to eq("changing carrier type")
      end
    end

    describe "new_copy_cards_item" do
      let(:cards) { 3 }
      let(:order_item) { described_class.new_copy_cards_item(cards) }

      it "has a type of 'COPY_CARDS'" do
        expect(order_item.type).to eq(described_class::TYPES[:copy_cards])
      end

      it "sets the correct amount" do
        expect(order_item.amount).to eq(3_000)
      end

      it "sets the correct quantity" do
        expect(order_item.quantity).to eq(3)
      end

      it "sets the correct description" do
        expect(order_item.description).to eq("3 registration cards")
      end

      context "when the number of cards is 1" do
        let(:cards) { 1 }

        it "sets the correct description" do
          expect(order_item.description).to eq("1 registration card")
        end
      end
    end
  end
end
