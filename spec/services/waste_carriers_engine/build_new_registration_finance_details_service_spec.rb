# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe BuildNewRegistrationFinanceDetailsService do
    describe ".run" do
      let(:transient_registration) do
        double(
          :transient_registration,
          contact_email: "user@example.com",
          temp_cards: 2,
          upper_tier?: true
        )
      end
      let(:order) { double(:order, order_items: []) }

      before do
        finance_details = double(:finance_details)
        order_item_cards = double(:order_item_cards, amount: 10)
        order_item_registration = double(:order_item_registration, amount: 20)
        orders = double(:orders)

        expect(FinanceDetails).to receive(:new).and_return(finance_details)
        expect(finance_details).to receive(:transient_registration=).with(transient_registration)
        expect(Order).to receive(:new_order_for).with("user@example.com").and_return(order)
        expect(OrderItem).to receive(:new_copy_cards_item).with(2).and_return(order_item_cards)
        expect(OrderItem).to receive(:new_registration_item).and_return(order_item_registration)
        expect(order).to receive(:set_description)
        expect(order).to receive(:order_items=).with([])
        expect(order).to receive(:total_amount=).with(30)

        expect(finance_details).to receive(:orders).and_return(orders).twice
        expect(orders).to receive(:<<).with(order)
        expect(finance_details).to receive(:update_balance)
        expect(finance_details).to receive(:save!)
      end

      context "when the payment method is bank transfer" do
        let(:payment_method) { :bank_transfer }

        it "updates the transient_registration's finance details with a new order for the given copy cards" do
          expect(order).to receive(:add_bank_transfer_attributes)

          described_class.run(transient_registration: transient_registration, payment_method: payment_method)
        end
      end

      context "when the payment method is worldpay" do
        let(:payment_method) { :worldpay }

        it "updates the transient_registration's finance details with a new order for the given copy cards" do
          expect(order).to receive(:add_worldpay_attributes)

          described_class.run(transient_registration: transient_registration, payment_method: payment_method)
        end
      end

      context "when the payment method is govpay" do
        let(:payment_method) { :govpay }

        it "updates the transient_registration's finance details with a new order for the given copy cards" do
          expect(order).to receive(:add_govpay_attributes)

          described_class.run(transient_registration: transient_registration, payment_method: payment_method)
        end
      end
    end
  end
end
