# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe ReceiptEmailForm, type: :model do
    describe "#submit" do
      context "when the form is valid" do
        let(:receipt_email_form) { build(:receipt_email_form, :has_required_data) }
        let(:valid_params) do
          { token: receipt_email_form.token, receipt_email: "foo@example.com" }
        end

        it "should submit" do
          expect(receipt_email_form.submit(valid_params)).to eq(true)
        end

        context "when the receipt email is nil" do
          let(:valid_params) do
            { token: receipt_email_form.token, receipt_email: nil }
          end

          it "should submit" do
            expect(receipt_email_form.submit(valid_params)).to eq(true)
          end
        end
      end

      context "when the form is not valid" do
        let(:receipt_email_form) { build(:receipt_email_form, :has_required_data) }
        let(:invalid_params) { { receipt_email: "foo" } }

        it "should not submit" do
          expect(receipt_email_form.submit(invalid_params)).to eq(false)
        end
      end
    end

    include_examples "validate email", :receipt_email_form, :receipt_email
  end
end
