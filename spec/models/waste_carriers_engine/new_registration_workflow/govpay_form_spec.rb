# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe NewRegistration do

    subject { build(:new_registration, workflow_state: "govpay_form") }

    describe "#workflow_state" do
      context "with :govpay_form state transitions" do
        context "with :next transition" do
          it_behaves_like "has next transition", next_state: "registration_completed_form"

          context "when there are pending convictions" do
            subject { build(:new_registration, :requires_conviction_check, workflow_state: "govpay_form") }

            it_behaves_like "has next transition", next_state: "registration_received_pending_conviction_form"
          end

          context "when there is a pending govpay payment" do
            let(:finance_details) { build(:finance_details, :has_pending_govpay_order) }

            subject { create(:new_registration, :has_pending_govpay_status, finance_details: finance_details, workflow_state: "govpay_form") }

            it_behaves_like "has next transition", next_state: "registration_received_pending_govpay_payment_form"
          end
        end
      end
    end
  end
end
