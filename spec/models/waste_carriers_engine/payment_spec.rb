# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe Payment do
    let(:transient_registration) { build(:renewing_registration, :has_required_data) }

    it_behaves_like "Can have payment type", resource: described_class.new

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
          cash_payment = described_class.new(payment_type: "CASH")
          refund_payment = described_class.new(payment_type: "REFUND")

          transient_registration.finance_details.payments << cash_payment
          transient_registration.finance_details.payments << refund_payment
          transient_registration.save
          transient_registration.reload

          result = transient_registration.finance_details.payments.refundable

          expect(result).to include(cash_payment)
          expect(result).not_to include(refund_payment)
        end
      end

      describe ".reversible" do
        let(:transient_registration) { build(:renewing_registration, :has_required_data, :has_finance_details) }

        it "returns a list of payments that have a type which can be reversed" do
          cash_payment = described_class.new(payment_type: "CASH")
          refund_payment = described_class.new(payment_type: "REFUND")

          transient_registration.finance_details.payments << cash_payment
          transient_registration.finance_details.payments << refund_payment
          transient_registration.save
          transient_registration.reload

          result = transient_registration.finance_details.payments.reversible

          expect(result).to include(cash_payment)
          expect(result).not_to include(refund_payment)
        end
      end

      describe ".except_online_not_authorised" do
        let(:transient_registration) { build(:renewing_registration, :has_required_data, :has_finance_details) }
        let(:cash_payment) { described_class.new(payment_type: "CASH") }
        let(:govpay_payment_authorised) { described_class.new(payment_type: "GOVPAY", govpay_payment_status: Payment::STATUS_SUCCESS) }
        let(:govpay_payment_refused) { described_class.new(payment_type: "GOVPAY", govpay_payment_status: Payment::STATUS_FAILED) }
        let(:refund_payment_success) { described_class.new(payment_type: "REFUND", govpay_payment_status: Payment::STATUS_SUCCESS) }
        let(:refund_payment_nil_status) { described_class.new(payment_type: "REFUND", govpay_payment_status: nil) }
        let(:refund_payment_failed) { described_class.new(payment_type: "REFUND", govpay_payment_status: Payment::STATUS_FAILED) }

        before do
          transient_registration.finance_details.payments << cash_payment << govpay_payment_authorised << govpay_payment_refused
          transient_registration.finance_details.payments << refund_payment_success << refund_payment_nil_status << refund_payment_failed
          transient_registration.save
          transient_registration.reload
        end

        it "returns the expected payments only" do
          result = transient_registration.finance_details.payments.except_online_not_authorised

          expect(result).to include(cash_payment)
          expect(result).to include(govpay_payment_authorised)
          expect(result).not_to include(govpay_payment_refused)
          expect(result).to include(refund_payment_success)
          expect(result).to include(refund_payment_nil_status)
          expect(result).not_to include(refund_payment_failed)
        end
      end
    end

    describe "new_from_online_payment" do
      before do
        Timecop.freeze(Time.new(2018, 1, 1)) do
          transient_registration.prepare_for_payment(:govpay)
        end
      end

      let(:order) { transient_registration.finance_details.orders.first }
      let(:payment) { described_class.new_from_online_payment(order, transient_registration.contact_email) }

      it "sets the correct order_key" do
        expect(payment.order_key).to eq("1514764800")
      end

      it "sets the correct amount" do
        expect(payment.amount).to eq(11_000)
      end

      it "sets the correct currency" do
        expect(payment.currency).to eq("GBP")
      end

      it "sets the correct payment_type" do
        expect(payment.payment_type).to eq("GOVPAY")
      end

      it "sets the correct registration_reference" do
        expect(payment.registration_reference).to eq("Govpay")
      end

      it "has the correct updated_by_user" do
        expect(payment.updated_by_user).to eq(transient_registration.contact_email)
      end

      it "sets the correct comment" do
        expect(payment.comment).to eq("Paid via Govpay")
      end
    end

    describe "new_from_non_online_payment" do
      before do
        Timecop.freeze(Time.new(2018, 1, 1)) do
          transient_registration.prepare_for_payment(:govpay)
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
          updated_by_user: transient_registration.contact_email
        }
      end

      let(:order) { transient_registration.finance_details.orders.first }
      let(:payment) { described_class.new_from_non_online_payment(params, order) }

      it "sets the correct amount" do
        expect(payment.amount).to eq(params[:amount])
      end

      it "sets the correct comment" do
        expect(payment.comment).to eq(params[:comment])
      end

      it "sets the correct currency" do
        expect(payment.currency).to eq("GBP")
      end

      it "sets the correct date_entered" do
        Timecop.freeze(Time.new(2018, 1, 1)) do
          expect(payment.date_entered).to eq(Date.new(2018, 1, 1))
        end
      end

      it "sets the correct date_received" do
        expect(payment.date_received).to eq(params[:date_received])
      end

      it "sets the correct date_received_day" do
        expect(payment.date_received_day).to eq(params[:date_received_day])
      end

      it "sets the correct date_received_month" do
        expect(payment.date_received_month).to eq(params[:date_received_month])
      end

      it "sets the correct date_received_year" do
        expect(payment.date_received_year).to eq(params[:date_received_year])
      end

      it "sets the correct order_key" do
        allow(SecureRandom).to receive(:uuid).and_return("__-1514764800")

        expect(payment.order_key).to eq("1514764800")
      end

      it "sets the correct payment_type" do
        expect(payment.payment_type).to eq(params[:payment_type])
      end

      it "sets the correct registration_reference" do
        expect(payment.registration_reference).to eq(params[:registration_reference])
      end

      it "sets the correct updated_by_user" do
        expect(payment.updated_by_user).to eq(params[:updated_by_user])
      end
    end

    describe "update_after_online_payment" do
      let(:order) { transient_registration.finance_details.orders.first }
      let(:payment) { described_class.new_from_online_payment(order, transient_registration.contact_email) }

      before do
        Timecop.freeze(Time.new(2018, 3, 4)) do
          transient_registration.prepare_for_payment(:govpay)
          payment.update_after_online_payment({ govpay_status: Payment::STATUS_CREATED })
        end
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
