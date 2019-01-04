# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe TransientRegistration, type: :model do
    describe "#workflow_state" do
      context "when a TransientRegistration's state is :payment_summary_form" do
        let(:transient_registration) do
          create(:transient_registration,
                 :has_required_data,
                 workflow_state: "payment_summary_form")
        end

        it "changes to :cards_form after the 'back' event" do
          expect(transient_registration).to transition_from(:payment_summary_form).to(:cards_form).on_event(:back)
        end

        context "when paying by card" do
          before(:each) { transient_registration.temp_payment_method = "card" }

          it "changes to :worldpay_form after the 'next' event" do
            expect(transient_registration).to transition_from(:payment_summary_form).to(:worldpay_form).on_event(:next)
          end
        end

        context "when paying by bank transfer" do
          before(:each) { transient_registration.temp_payment_method = "bank_transfer" }

          it "changes to :bank_transfer_form after the 'next' event" do
            expect(transient_registration).to transition_from(:payment_summary_form).to(:bank_transfer_form).on_event(:next)
          end
        end
      end
    end
  end
end
