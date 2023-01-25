# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "PaymentSummaryForms" do
    include_examples "GET locked-in form", "payment_summary_form"

    describe "POST payment_summary_form_path" do
      include_examples "POST renewal form",
                       "payment_summary_form",
                       valid_params: { temp_payment_method: "card", card_confirmation_email: "foo@example.com" },
                       invalid_params: { temp_payment_method: "foo" },
                       test_attribute: :temp_payment_method

      context "when govpay is enabled" do
        before { create(:feature_toggle, :govpay_payments) }

        include_examples "POST renewal form",
                         "payment_summary_form",
                         valid_params: { temp_payment_method: "card", card_confirmation_email: "foo@example.com" },
                         invalid_params: { temp_payment_method: "foo" },
                         test_attribute: :temp_payment_method
      end

      context "when the transient_registration is a new registration" do
        let(:transient_registration) do
          create(:new_registration, workflow_state: "payment_summary_form")
        end

        include_examples "POST form",
                         "payment_summary_form",
                         valid_params: { temp_payment_method: "card", card_confirmation_email: "foo@example.com" },
                         invalid_params: { temp_payment_method: "foo" }
      end
    end
  end
end
