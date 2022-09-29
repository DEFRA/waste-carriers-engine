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

        allow(FinanceDetails).to receive(:new).and_return(finance_details)
        allow(finance_details).to receive(:transient_registration=).with(transient_registration)
        allow(Order).to receive(:new_order_for).with("user@example.com").and_return(order)
        allow(OrderItem).to receive(:new_copy_cards_item).with(2).and_return(order_item_cards)
        allow(OrderItem).to receive(:new_registration_item).and_return(order_item_registration)
        allow(order).to receive(:set_description)
        allow(order).to receive(:order_items=).with([])
        allow(order).to receive(:total_amount=).with(30)
        allow(finance_details).to receive(:orders).and_return(orders).twice
        allow(orders).to receive(:<<).with(order)
        allow(finance_details).to receive(:update_balance)
        allow(finance_details).to receive(:save!)
      end

      context "when the payment method is bank transfer" do
        let(:payment_method) { :bank_transfer }

        it "updates the transient_registration's finance details with a new order for the given copy cards" do
          allow(order).to receive(:add_bank_transfer_attributes)

          described_class.run(transient_registration: transient_registration, payment_method: payment_method)

          expect(order).to have_received(:add_bank_transfer_attributes)
        end
      end

      context "when the payment method is worldpay" do
        let(:payment_method) { :worldpay }

        it "updates the transient_registration's finance details with a new order for the given copy cards" do
          allow(order).to receive(:add_worldpay_attributes)

          described_class.run(transient_registration: transient_registration, payment_method: payment_method)

          expect(order).to have_received(:add_worldpay_attributes)
        end
      end

      context "when the payment method is govpay" do
        let(:payment_method) { :govpay }

        it "updates the transient_registration's finance details with a new order for the given copy cards" do
          allow(order).to receive(:add_govpay_attributes)

          described_class.run(transient_registration: transient_registration, payment_method: payment_method)

          expect(order).to have_received(:add_govpay_attributes)
        end
      end
    end
  end
end
