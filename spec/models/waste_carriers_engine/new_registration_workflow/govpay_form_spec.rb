# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe NewRegistration do
    before { allow(WasteCarriersEngine::FeatureToggle).to receive(:active?).with(:govpay_payments).and_return(true) }

    subject { build(:new_registration, workflow_state: "govpay_form") }

    describe "#workflow_state" do
      context ":govpay_form state transitions" do
        context "on next" do
          include_examples "has next transition", next_state: "registration_completed_form"

          context "when there are pending convictions" do
            subject { build(:new_registration, :requires_conviction_check, workflow_state: "govpay_form") }

            include_examples "has next transition", next_state: "registration_received_pending_conviction_form"
          end

          context "when there is a pending govpay payment" do
            subject { build(:new_registration, :has_pending_govpay_status, workflow_state: "govpay_form") }

            include_examples "has next transition", next_state: "registration_received_pending_govpay_payment_form"
          end
        end
      end
    end
  end
end
