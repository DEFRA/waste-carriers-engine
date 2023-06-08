# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe RenewingRegistration do
    subject do
      build(:renewing_registration,
            :has_required_data,
            temp_payment_method: temp_payment_method,
            workflow_state: "payment_summary_form")
    end
    let(:temp_payment_method) { nil }

    describe "#workflow_state" do
      context "with :payment_summary_form state transitions" do
        context "with :next transition" do
          context "when paying by card" do
            let(:temp_payment_method) { "card" }

            include_examples "has next transition", next_state: "payment_method_confirmation_form"
          end

          context "when paying by bank transfer" do
            let(:temp_payment_method) { "bank_transfer" }

            include_examples "has next transition", next_state: "payment_method_confirmation_form"
          end
        end
      end
    end
  end
end
