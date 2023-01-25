# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe FinanceDetails do
    before do
      allow(Rails.configuration).to receive(:renewal_charge).and_return(10_000)
      allow(Rails.configuration).to receive(:type_change_charge).and_return(2_500)
      allow(Rails.configuration).to receive(:card_charge).and_return(1_000)
    end

    let(:transient_registration) { build(:renewing_registration, :has_required_data, temp_cards: 0) }
    let(:current_user) { build(:user) }

    describe "new_finance_details" do
      let(:finance_details) { transient_registration.prepare_for_payment(:worldpay, current_user) }

      it "includes 1 order" do
        order_count = finance_details.orders.length
        expect(order_count).to eq(1)
      end

      it "has the correct balance" do
        expect(finance_details.balance).to eq(10_000)
      end

      it "persists" do
        expect(finance_details.persisted?).to be true
      end
    end

    describe "zero_difference_balance" do
      let(:transient_registration) { build(:renewing_registration, :has_required_data, :has_finance_details) }

      subject(:finance_details) { transient_registration.finance_details }

      before do
        transient_registration.finance_details.balance = balance
      end

      context "when the balance is 0" do
        let(:balance) { 0 }

        it "returns 0" do
          expect(finance_details.zero_difference_balance).to be_zero
        end
      end

      context "when the balance is less than 0" do
        let(:balance) { -4 }

        it "returns the difference from 0 balance" do
          expect(finance_details.zero_difference_balance).to eq(4)
        end
      end

      context "when the balance is more than 0" do
        let(:balance) { 4 }

        it "returns the difference from 0 balance" do
          expect(finance_details.zero_difference_balance).to eq(4)
        end
      end
    end

    describe "overpaid_balance" do
      let(:transient_registration) { build(:renewing_registration, :has_required_data, :has_finance_details) }

      subject(:finance_details) { transient_registration.finance_details }

      before do
        transient_registration.finance_details.balance = balance
      end

      context "when the balance is 0" do
        let(:balance) { 0 }

        it "returns 0" do
          expect(finance_details.overpaid_balance).to be_zero
        end
      end

      context "when the balance is less than 0" do
        let(:balance) { -4 }

        it "returns the balance but in positive" do
          expect(finance_details.overpaid_balance).to eq(4)
        end
      end

      context "when the balaance is more than 0" do
        let(:balance) { 4 }

        it "returns 0" do
          expect(finance_details.overpaid_balance).to be_zero
        end
      end
    end

    describe "unpaid_balance" do
      let(:transient_registration) { build(:renewing_registration, :has_required_data, :has_finance_details) }

      subject(:finance_details) { transient_registration.finance_details }

      before do
        transient_registration.finance_details.balance = balance
      end

      context "when the balance is 0" do
        let(:balance) { 0 }

        it "returns 0" do
          expect(finance_details.unpaid_balance).to be_zero
        end
      end

      context "when the balance is more than 0" do
        let(:balance) { 4 }

        it "returns the balance" do
          expect(finance_details.unpaid_balance).to eq(4)
        end
      end

      context "when the balaance is less than 0" do
        let(:balance) { -4 }

        it "returns 0" do
          expect(finance_details.unpaid_balance).to be_zero
        end
      end
    end

    describe "update_balance" do
      let(:finance_details) { build(:finance_details) }

      it "has the correct balance" do
        finance_details.update_balance
        expect(finance_details.balance).to eq(0)
      end

      context "when there is an order" do
        before do
          finance_details.orders = [Order.new_order(transient_registration, :worldpay, current_user)]
        end

        it "has the correct balance" do
          finance_details.update_balance
          expect(finance_details.balance).to eq(10_000)
        end

        context "when there is also a WorldPay payment" do
          before do
            finance_details.payments = [build(:payment, :worldpay, amount: 5_000, world_pay_payment_status: "AUTHORISED")]
          end

          it "has the correct balance" do
            finance_details.update_balance
            expect(finance_details.balance).to eq(5_000)
          end
        end

        context "when the WorldPay payment is not authorised" do
          before do
            finance_details.payments = [build(:payment, :worldpay, amount: 5_000, world_pay_payment_status: "REFUSED")]
          end

          it "does not include it when calculating the balance" do
            finance_details.update_balance
            expect(finance_details.balance).to eq(10_000)
          end
        end

        context "when the payment is non-WorldPay" do
          before do
            finance_details.payments = [build(:payment, :bank_transfer, amount: 5_000)]
          end

          it "has the correct balance" do
            finance_details.update_balance
            expect(finance_details.balance).to eq(5_000)
          end
        end
      end

      context "when there is a payment only" do
        before do
          finance_details.payments = [build(:payment, :worldpay, amount: 5_000, world_pay_payment_status: "AUTHORISED")]
        end

        it "has the correct balance" do
          finance_details.update_balance
          expect(finance_details.balance).to eq(-5_000)
        end
      end
    end
  end
end
