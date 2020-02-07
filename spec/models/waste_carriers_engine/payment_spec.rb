# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe Payment, type: :model do
    let(:transient_registration) { build(:renewing_registration, :has_required_data) }
    let(:current_user) { build(:user) }

    it_should_behave_like "Can have payment type", resource: described_class.new

    describe "default attributes" do
      describe ".currency" do
        it "initialize currency as GBP" do
          payment = described_class.new

          expect(payment.currency).to eq("GBP")
        end
      end
    end

    describe "scopes" do
      describe ".refundable" do
        let(:transient_registration) { build(:renewing_registration, :has_required_data, :has_finance_details) }

        it "returns a list of payments that have a type which can be refunded" do
          cash_payment = WasteCarriersEngine::Payment.new(payment_type: "CASH")
          refund_payment = WasteCarriersEngine::Payment.new(payment_type: "REFUND")

          transient_registration.finance_details.payments << cash_payment
          transient_registration.finance_details.payments << refund_payment
          transient_registration.save
          transient_registration.reload

          result = transient_registration.finance_details.payments.refundable

          expect(result).to include(cash_payment)
          expect(result).to_not include(refund_payment)
        end
      end

      describe ".reversible" do
        let(:transient_registration) { build(:renewing_registration, :has_required_data, :has_finance_details) }

        it "returns a list of payments that have a type which can be reversed" do
          cash_payment = WasteCarriersEngine::Payment.new(payment_type: "CASH")
          refund_payment = WasteCarriersEngine::Payment.new(payment_type: "REFUND")

          transient_registration.finance_details.payments << cash_payment
          transient_registration.finance_details.payments << refund_payment
          transient_registration.save
          transient_registration.reload

          result = transient_registration.finance_details.payments.reversible

          expect(result).to include(cash_payment)
          expect(result).to_not include(refund_payment)
        end
      end
    end

    describe "new_from_worldpay" do
      before do
        Timecop.freeze(Time.new(2018, 1, 1)) do
          transient_registration.prepare_for_payment(:worldpay, current_user)
        end
      end

      let(:order) { transient_registration.finance_details.orders.first }
      let(:payment) { Payment.new_from_worldpay(order, current_user) }

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
        expect(payment.updated_by_user).to eq(current_user.email)
      end

      it "should set the correct comment" do
        expect(payment.comment).to eq("Paid via Worldpay")
      end
    end

    describe "new_from_non_worldpay" do
      before do
        Timecop.freeze(Time.new(2018, 1, 1)) do
          transient_registration.prepare_for_payment(:worldpay, current_user)
        end
      end

      let(:params) do
        {
          amount: 100,
          comment: "foo",
          date_received: Date.new(2018, 1, 1),
          date_received_day: 1,
          date_received_month: 1,
          date_received_year: 2018,
          payment_type: "BANKTRANSFER",
          registration_reference: "foo",
          updated_by_user: current_user.email
        }
      end

      let(:order) { transient_registration.finance_details.orders.first }
      let(:payment) { Payment.new_from_non_worldpay(params, order) }

      it "should set the correct amount" do
        expect(payment.amount).to eq(params[:amount])
      end

      it "should set the correct comment" do
        expect(payment.comment).to eq(params[:comment])
      end

      it "should set the correct currency" do
        expect(payment.currency).to eq("GBP")
      end

      it "should set the correct date_entered" do
        Timecop.freeze(Time.new(2018, 1, 1)) do
          expect(payment.date_entered).to eq(Date.new(2018, 1, 1))
        end
      end

      it "should set the correct date_received" do
        expect(payment.date_received).to eq(params[:date_received])
      end

      it "should set the correct date_received_day" do
        expect(payment.date_received_day).to eq(params[:date_received_day])
      end

      it "should set the correct date_received_month" do
        expect(payment.date_received_month).to eq(params[:date_received_month])
      end

      it "should set the correct date_received_year" do
        expect(payment.date_received_year).to eq(params[:date_received_year])
      end

      it "should set the correct order_key" do
        expect(SecureRandom).to receive(:uuid).and_return("__-1514764800")

        expect(payment.order_key).to eq("1514764800")
      end

      it "should set the correct payment_type" do
        expect(payment.payment_type).to eq(params[:payment_type])
      end

      it "should set the correct registration_reference" do
        expect(payment.registration_reference).to eq(params[:registration_reference])
      end

      it "should set the correct updated_by_user" do
        expect(payment.updated_by_user).to eq(params[:updated_by_user])
      end
    end

    describe "update_after_worldpay" do
      let(:order) { transient_registration.finance_details.orders.first }
      let(:payment) { Payment.new_from_worldpay(order, current_user) }

      before do
        Timecop.freeze(Time.new(2018, 3, 4)) do
          transient_registration.prepare_for_payment(:worldpay, current_user)
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
