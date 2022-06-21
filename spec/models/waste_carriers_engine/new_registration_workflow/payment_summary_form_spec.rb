# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe NewRegistration do
    subject { build(:new_registration, workflow_state: "payment_summary_form") }

    describe "#workflow_state" do
      context ":payment_summary_form state transitions" do
        context "on next" do
          context "when the user chooses to pay by card" do
            subject { build(:new_registration, workflow_state: "payment_summary_form", temp_payment_method: "card") }

            context "and Worldpay payments are enabled" do
              include_examples "has next transition", next_state: "worldpay_form"
            end

            context "and Govpay payments are enabled" do
              before { allow(WasteCarriersEngine::FeatureToggle).to receive(:active?).with(:govpay_payments).and_return(true) }
              include_examples "has next transition", next_state: "govpay_form"
            end
          end

          include_examples "has next transition", next_state: "confirm_bank_transfer_form"
        end
      end
    end
  end
end
