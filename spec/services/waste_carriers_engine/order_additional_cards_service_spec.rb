# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe OrderAdditionalCardsService do
    describe ".run" do
      let(:user) { double(:user) }
      let(:registration) { double(:registration) }
      let(:order) { double(:order) }

      before do
        finance_details = double(:finance_details)
        order_item = double(:order_item)
        orders = double(:orders)

        expect(registration).to receive(:finance_details).and_return(finance_details)
        expect(Order).to receive(:new_order_for).with(user).and_return(order)
        expect(OrderItem).to receive(:new_copy_cards_item).with(2).and_return(order_item)
        expect(order).to receive(:generate_description)
        expect(order).to receive(:[]=).with(:order_items, [order_item])
        expect(order_item).to receive(:[]).with(:amount).and_return(10)
        expect(order).to receive(:[]=).with(:total_amount, 10)

        expect(finance_details).to receive(:[]).with(:orders).and_return(orders)
        expect(orders).to receive(:<<).with(order)
        expect(finance_details).to receive(:update_balance)
        expect(finance_details).to receive(:save!)
      end

      context "when the payment method is bank transfer" do
        let(:payment_method) { :bank_transfer }

        it "updates the registration's finance details with a new order for the given copy cards" do
          expect(order).to receive(:add_bank_transfer_attributes)

          described_class.run(cards_count: 2, user: user, registration: registration, payment_method: payment_method)
        end
      end

      context "when the payment method is worldpay" do
        let(:payment_method) { :worldpay }

        it "updates the registration's finance details with a new order for the given copy cards" do
          expect(order).to receive(:add_worldpay_attributes)

          described_class.run(cards_count: 2, user: user, registration: registration, payment_method: payment_method)
        end
      end
    end
  end
end
