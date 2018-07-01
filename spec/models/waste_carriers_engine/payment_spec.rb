require "rails_helper"

module WasteCarriersEngine
  RSpec.describe Payment, type: :model do
    let(:transient_registration) { build(:transient_registration, :has_required_data) }

    describe "new_from_worldpay" do
      before do
        Timecop.freeze(Time.new(2018, 1, 1)) do
          FinanceDetails.new_finance_details(transient_registration, :worldpay)
        end
      end

      let(:order) { transient_registration.finance_details.orders.first }
      let(:payment) { Payment.new_from_worldpay(order) }

      it "should set the correct order_key" do
        expect(payment.order_key).to eq("1514764800")
      end

      it "should set the correct amount" do
        expect(payment.amount).to eq(11_000)
      end

      it "should set the correct currency" do
        expect(payment.currency).to eq("GBP")
      end

      it "should set the correct payment_type" do
        expect(payment.payment_type).to eq("WORLDPAY")
      end

      it "should set the correct registration_reference" do
        expect(payment.registration_reference).to eq("Worldpay")
      end

      it "should have the correct updated_by_user" do
        expect(payment.updated_by_user).to eq("foo@example.com")
      end

      it "should set the correct comment" do
        expect(payment.comment).to eq("Paid via Worldpay")
      end
    end

    describe "update_after_worldpay" do
      let(:order) { transient_registration.finance_details.orders.first }
      let(:payment) { Payment.new_from_worldpay(order) }

      before do
        Timecop.freeze(Time.new(2018, 3, 4)) do
          FinanceDetails.new_finance_details(transient_registration, :worldpay)
          payment.update_after_worldpay(paymentStatus: "AUTHORISED", mac: "foo")
        end
      end

      it "updates the payment status" do
        expect(payment.world_pay_payment_status).to eq("AUTHORISED")
      end

      it "updates the payment mac_code" do
        expect(payment.mac_code).to eq("foo")
      end

      it "updates the payment date_received" do
        expect(payment.date_received).to eq(Date.new(2018, 3, 4))
      end

      it "updates the payment date_entered" do
        expect(payment.date_entered).to eq(Date.new(2018, 3, 4))
      end

      it "updates the payment date_received_year" do
        expect(payment.date_received_year).to eq(2018)
      end

      it "updates the payment date_received_month" do
        expect(payment.date_received_month).to eq(3)
      end

      it "updates the payment date_received_day" do
        expect(payment.date_received_day).to eq(4)
      end
    end
  end
end
