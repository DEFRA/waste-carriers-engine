# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe NewRegistration do
    subject { build(:new_registration, workflow_state: "worldpay_form") }

    describe "#workflow_state" do
      context "with :worldpay_form state transitions" do
        context "with :next transition" do
          include_examples "has next transition", next_state: "registration_completed_form"

          context "when there are pending convictions" do
            subject { build(:new_registration, :requires_conviction_check, workflow_state: "worldpay_form") }

            include_examples "has next transition", next_state: "registration_received_pending_conviction_form"
          end

          context "when there is a pending worldpay payment" do
            subject { build(:new_registration, :has_pending_worldpay_status, workflow_state: "worldpay_form") }

            include_examples "has next transition", next_state: "registration_received_pending_worldpay_payment_form"
          end
        end
      end
    end
  end
end
