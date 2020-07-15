# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe PaymentSummaryForm, type: :model do
    describe "#submit" do
      context "when the form is valid" do
        let(:payment_summary_form) { build(:payment_summary_form, :has_required_data) }
        let(:valid_params) do
          {
            token: payment_summary_form.token,
            temp_payment_method: payment_summary_form.temp_payment_method,
            receipt_email: "foo@example.com"
          }
        end

        it "should submit" do
          expect(payment_summary_form.submit(valid_params)).to eq(true)
        end
      end

      context "when the form is not valid" do
        let(:payment_summary_form) { build(:payment_summary_form, :has_required_data) }
        let(:invalid_params) do
          {
            token: payment_summary_form.token,
            temp_payment_method: "foo",
            receipt_email: "foo@com"
          }
        end

        it "should not submit" do
          expect(payment_summary_form.submit(invalid_params)).to eq(false)
        end
      end
    end

    describe "#valid?" do
      context "when a valid transient registration exists" do
        let(:payment_summary_form) { build(:payment_summary_form, :has_required_data) }

        before do
          payment_summary_form.transient_registration.temp_payment_method = temp_payment_method
        end

        context "when a temp_payment_method is bank_transfer" do
          let(:temp_payment_method) { "bank_transfer" }

          it "is valid" do
            expect(payment_summary_form).to be_valid
          end

          context "but the receipt email has been set" do
            before do
              payment_summary_form.transient_registration.receipt_email = receipt_email
            end

            context "to something invalid" do
              let(:receipt_email) { "foo@bar" }

              it "is still valid" do
                expect(payment_summary_form).to be_valid
              end
            end

            context "to nothing" do
              let(:receipt_email) { "" }

              it "is still valid" do
                expect(payment_summary_form).to be_valid
              end
            end
          end
        end

        context "when a temp_payment_method is card" do
          let(:temp_payment_method) { "card" }

          it "is valid" do
            expect(payment_summary_form).to be_valid
          end

          context "and the receipt email has been set" do
            before do
              payment_summary_form.transient_registration.receipt_email = receipt_email
            end

            context "to something invalid" do
              let(:receipt_email) { "foo@bar" }

              it "is is not valid" do
                expect(payment_summary_form).not_to be_valid
              end
            end

            context "to nothing" do
              let(:receipt_email) { "" }

              it "is is not valid" do
                expect(payment_summary_form).not_to be_valid
              end
            end
          end
        end

        context "when a temp_payment_method is anything else" do
          let(:temp_payment_method) { "I am a payment method, don't you know?" }

          it "is not valid" do
            expect(payment_summary_form).to_not be_valid
          end
        end
      end
    end
  end
end
