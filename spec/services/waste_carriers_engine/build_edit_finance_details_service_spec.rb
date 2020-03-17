# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe BuildEditFinanceDetailsService do
    describe ".run" do
      let(:user) { double(:user) }
      let(:transient_registration) { double(:transient_registration) }
      let(:order) { double(:order) }

      before do
        finance_details = double(:finance_details)
        order_item = double(:order_item)
        orders = double(:orders)

        expect(FinanceDetails).to receive(:new).and_return(finance_details)
        expect(finance_details).to receive(:transient_registration=).with(transient_registration)
        expect(Order).to receive(:new_order_for).with(user).and_return(order)
        expect(transient_registration).to receive(:registration_type_changed?).and_return(true)
        expect(OrderItem).to receive(:new_type_change_item).and_return(order_item)
        expect(order).to receive(:generate_description)
        expect(order).to receive(:[]=).with(:order_items, [order_item])
        expect(order_item).to receive(:[]).with(:amount).and_return(40)
        expect(order).to receive(:[]=).with(:total_amount, 40)

        expect(finance_details).to receive(:[]).with(:orders).and_return(orders).twice
        expect(orders).to receive(:<<).with(order)
        expect(finance_details).to receive(:update_balance)
        expect(finance_details).to receive(:save!)
      end

      context "when the payment method is bank transfer" do
        let(:payment_method) { :bank_transfer }

        it "updates the transient_registration's finance details with a new order for the change fee" do
          expect(order).to receive(:add_bank_transfer_attributes)

          described_class.run(user: user, transient_registration: transient_registration, payment_method: payment_method)
        end
      end

      context "when the payment method is worldpay" do
        let(:payment_method) { :worldpay }

        it "updates the transient_registration's finance details with a new order for the change fee" do
          expect(order).to receive(:add_worldpay_attributes)

          described_class.run(user: user, transient_registration: transient_registration, payment_method: payment_method)
        end
      end
    end
  end
end
