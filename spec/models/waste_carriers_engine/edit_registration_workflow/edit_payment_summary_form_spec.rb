# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe EditRegistration do
    subject { build(:edit_registration, workflow_state: "edit_payment_summary_form") }

    describe "#workflow_state" do
      context "with :payment_summary_form state transitions" do
        context "with :next transition" do
          context "when the payment type is :card" do
            subject { build(:edit_registration, workflow_state: "edit_payment_summary_form", temp_payment_method: "card") }

            include_examples "has next transition", next_state: "worldpay_form"
          end

          include_examples "has next transition", next_state: "edit_bank_transfer_form"
        end
      end
    end
  end
end
