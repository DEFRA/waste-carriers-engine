# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe OrderAndTotalPresenter do
    subject { described_class.new(form, view) }

    let(:form) { double(:form, transient_registration: transient_registration) }
    let(:transient_registration) do
      double(:transient_registration,
             finance_details: finance_details,
             temp_cards: temp_cards)
    end
    let(:temp_cards) { 2 }

    let(:finance_details) { double(:finance_details, balance: balance, orders: orders) }
    let(:balance) { 0 }
    let(:orders) { [order] }
    let(:order) { double(:order, order_items: order_items) }

    let(:order_items) { [renewal_order_item, edit_order_item, copy_cards_order_item, charge_adjust_order_item] }
    let(:renewal_order_item) { double(:order_item, type: OrderItem::TYPES[:renew], amount: 10_500) }
    let(:edit_order_item) { double(:order_item, type: OrderItem::TYPES[:edit], amount: 4_000) }
    let(:copy_cards_order_item) { double(:order_item, type: OrderItem::TYPES[:copy_cards], amount: 1_000) }
    let(:charge_adjust_order_item) { double(:order_item, type: OrderItem::TYPES[:charge_adjust], amount: 500) }

    describe "#order_items" do
      it "returns a correctly-formatted list with descriptions and values" do
        expected_list = [
          {
            description: "Renewal of registration",
            cost: 10_500
          },
          {
            description: "Additional charge for changing registration type",
            cost: 4_000
          },
          {
            description: "2 registration cards total cost",
            cost: 1_000
          },
          {
            description: "Charge adjust",
            cost: 500
          }
        ]
        expect(subject.order_items).to eq(expected_list)
      end
    end

    describe "#total_cost" do
      it "returns the balance" do
        expect(subject.total_cost).to eq(balance)
      end
    end
  end
end
