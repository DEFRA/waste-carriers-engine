# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe GovpayUpdateRefundStatusService do

    describe "#run" do
      let(:registration) { create(:registration, :has_required_data, finance_details: build(:finance_details, :has_overpaid_order_and_payment_govpay)) }
      let(:payment) { registration.finance_details.payments.first }
      let(:refund_amount) { payment.amount - 100 }
      let(:refund) { build(:payment, :govpay_refund_pending, amount: refund_amount, refunded_payment_govpay_id: payment.govpay_id) }
      let(:refund_id) { refund.govpay_id }

      before { registration.finance_details.payments << refund }

      subject(:run_service) { described_class.new.run(refund:, new_status: refund_status) }

      context "when the refund status has not changed" do
        let(:refund_status) { Payment::STATUS_SUBMITTED }

        it { expect(run_service).to be false }
        it { expect { run_service }.not_to change { refund.reload.govpay_payment_status } }
        it { expect { run_service }.not_to change { registration.reload.finance_details.balance } }
      end

      context "when the refund status has changed to error" do
        let(:refund_status) { "error" }

        it { expect(run_service).to be false }
        it { expect { run_service }.not_to change { refund.reload.govpay_payment_status } }
        it { expect { run_service }.not_to change { registration.reload.finance_details.balance } }
      end

      context "when the refund status has changed to success" do
        let(:refund_status) { Payment::STATUS_SUCCESS }

        it { expect(run_service).to be true }
        it { expect { run_service }.to change { refund.reload.govpay_payment_status }.to(Payment::STATUS_SUCCESS) }
        it { expect { run_service }.to change { registration.reload.finance_details.balance }.by(-refund_amount) }
      end

      context "when the registration is not found" do
        let(:refund_status) { Payment::STATUS_SUCCESS }

        before { allow(GovpayFindRegistrationService).to receive(:run).and_return(nil) }

        it { expect { run_service }.to raise_error(StandardError) }
      end
    end
  end
end
