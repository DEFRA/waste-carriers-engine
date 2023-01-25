# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe PaymentSummaryForm do
    describe "#submit" do
      let(:payment_summary_form) { build(:payment_summary_form, :has_required_data) }

      context "when hosted in the front-office" do
        let(:params) do
          {
            token: payment_summary_form.token,
            temp_payment_method: payment_method,
            card_confirmation_email: card_confirmation_email
          }
        end

        context "when the form is valid" do
          let(:payment_method) { "card" }
          let(:card_confirmation_email) { "foo@example.com" }

          it "submits" do
            expect(payment_summary_form.submit(params)).to be true
          end
        end

        context "when the form is not valid" do
          let(:payment_method) { "foo" }
          let(:card_confirmation_email) { "foo@com" }

          it "does not submit" do
            expect(payment_summary_form.submit(params)).to be false
          end
        end
      end

      context "when hosted in the back-office" do
        before do
          allow(WasteCarriersEngine.configuration).to receive(:host_is_back_office?).and_return(true)
        end

        let(:params) do
          {
            token: payment_summary_form.token,
            temp_payment_method: payment_method
          }
        end

        context "when the form is valid" do
          let(:payment_method) { "card" }

          it "submits" do
            expect(payment_summary_form.submit(params)).to be true
          end
        end

        context "when the form is not valid" do
          let(:payment_method) { "foo" }

          it "does not submit" do
            expect(payment_summary_form.submit(params)).to be false
          end
        end
      end

    end

    describe "#valid?" do
      before do
        payment_summary_form.transient_registration.temp_payment_method = temp_payment_method
      end

      context "when hosted in the front-office" do
        let(:payment_summary_form) do
          build(
            :payment_summary_form,
            :has_required_data,
            temp_payment_method: temp_payment_method,
            card_confirmation_email: card_confirmation_email
          )
        end

        context "when the temp_payment_method is card" do
          let(:temp_payment_method) { "card" }
          let(:card_confirmation_email) { "hello@example.com" }

          it "is valid" do
            expect(payment_summary_form).to be_valid
          end

          context "when the receipt email has been set" do
            context "when to something invalid" do
              let(:card_confirmation_email) { "foo@bar" }

              it "is not valid" do
                expect(payment_summary_form).not_to be_valid
              end
            end

            context "when set to nothing" do
              let(:card_confirmation_email) { "" }

              it "is not valid" do
                expect(payment_summary_form).not_to be_valid
              end
            end
          end
        end

        context "when the temp_payment_method is anything else" do
          let(:temp_payment_method) { "I am a payment method, don't you know?" }
          let(:card_confirmation_email) { "hello@example.com" }

          it "is not valid" do
            expect(payment_summary_form).not_to be_valid
          end
        end
      end

      context "when hosted in the back-office" do
        before do
          allow(WasteCarriersEngine.configuration).to receive(:host_is_back_office?).and_return(true)
        end

        let(:payment_summary_form) do
          build(
            :payment_summary_form,
            :has_required_data,
            temp_payment_method: temp_payment_method
          )
        end

        context "when the temp_payment_method is card" do
          let(:temp_payment_method) { "card" }

          it "is valid" do
            expect(payment_summary_form).to be_valid
          end
        end

        context "when the temp_payment_method is anything else" do
          let(:temp_payment_method) { "I am a payment method, don't you know?" }

          it "is not valid" do
            expect(payment_summary_form).not_to be_valid
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
      let(:payment_summary_form) { described_class.new(transient_registration) }

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
