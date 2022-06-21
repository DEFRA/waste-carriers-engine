# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe RenewingRegistration, type: :model do
    subject do
      build(:renewing_registration,
            :has_required_data,
            temp_payment_method: temp_payment_method,
            workflow_state: "payment_summary_form")
    end
    let(:temp_payment_method) {}

    describe "#workflow_state" do
      context ":payment_summary_form state transitions" do
        context "on next" do
          context "when paying by card" do
            let(:temp_payment_method) { "card" }

            context "and Worldpay payments are enabled" do
              include_examples "has next transition", next_state: "worldpay_form"
            end

            context "and Govpay payments are enabled" do
              before { allow(WasteCarriersEngine::FeatureToggle).to receive(:active?).with(:govpay_payments).and_return(true) }
              include_examples "has next transition", next_state: "govpay_form"
            end
          end

          context "when paying by bank transfer" do
            let(:temp_payment_method) { "bank_transfer" }

            include_examples "has next transition", next_state: "confirm_bank_transfer_form"
          end
        end
      end
    end
  end
end
