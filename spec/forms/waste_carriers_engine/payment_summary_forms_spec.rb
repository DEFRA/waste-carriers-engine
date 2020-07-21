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
            card_confirmation_email: "foo@example.com"
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
            card_confirmation_email: "foo@com"
          }
        end

        it "should not submit" do
          expect(payment_summary_form.submit(invalid_params)).to eq(false)
        end
      end
    end

    describe "#valid?" do
      context "when a valid transient registration exists" do
        let(:payment_summary_form) do
          build(
            :payment_summary_form,
            :has_required_data,
            temp_payment_method: temp_payment_method,
            card_confirmation_email: card_confirmation_email
          )
        end

        before do
          payment_summary_form.transient_registration.temp_payment_method = temp_payment_method
        end

        context "when a temp_payment_method is bank_transfer" do
          let(:temp_payment_method) { "bank_transfer" }
          let(:card_confirmation_email) { "hello@example.com" }

          it "is valid" do
            expect(payment_summary_form).to be_valid
          end

          context "but the card_confirmation_email has been set" do
            context "to something invalid" do
              let(:card_confirmation_email) { "foo@bar" }

              it "is still valid" do
                expect(payment_summary_form).to be_valid
              end
            end

            context "to nothing" do
              let(:card_confirmation_email) { "" }

              it "is still valid" do
                expect(payment_summary_form).to be_valid
              end
            end
          end
        end

        context "when a temp_payment_method is card" do
          let(:temp_payment_method) { "card" }
          let(:card_confirmation_email) { "hello@example.com" }

          it "is valid" do
            expect(payment_summary_form).to be_valid
          end

          context "and the receipt email has been set" do
            context "to something invalid" do
              let(:card_confirmation_email) { "foo@bar" }

              it "is not valid" do
                expect(payment_summary_form).not_to be_valid
              end
            end

            context "to nothing" do
              let(:card_confirmation_email) { "" }

              it "is not valid" do
                expect(payment_summary_form).not_to be_valid
              end
            end
          end
        end

        context "when a temp_payment_method is anything else" do
          let(:temp_payment_method) { "I am a payment method, don't you know?" }
          let(:card_confirmation_email) { "hello@example.com" }

          it "is not valid" do
            expect(payment_summary_form).to_not be_valid
          end
        end
      end
    end

    describe "#card_confirmation_email" do
      let(:transient_registration) do
        build(
          :renewing_registration,
          :has_required_data,
          workflow_state: "payment_summary_form",
          contact_email: contact_email,
          receipt_email: receipt_email
        )
      end
      # Don't use FactoryBot for this as we need to make sure it initializes with a specific object
      let(:payment_summary_form) { PaymentSummaryForm.new(transient_registration) }

      context "when initialised with a transient_registration with only contact email set" do
        let(:contact_email) { "contact@example.com" }
        let(:receipt_email) { nil }

        it "defaults to the contact email" do
          expect(payment_summary_form.card_confirmation_email).to eq(contact_email)
        end
      end

      context "when initialised with a transient_registration with both contact and receipt email set" do
        let(:contact_email) { "contact@example.com" }
        let(:receipt_email) { "receipt@example.com" }

        it "defaults to the receipt email" do
          expect(payment_summary_form.card_confirmation_email).to eq(receipt_email)
        end
      end
    end

    include_examples "validate email", :payment_summary_form, :card_confirmation_email
  end
end
