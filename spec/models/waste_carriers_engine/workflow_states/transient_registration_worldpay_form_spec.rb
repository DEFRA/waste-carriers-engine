# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe TransientRegistration, type: :model do
    describe "#workflow_state" do
      context "when a TransientRegistration's state is :worldpay_form" do
        let(:transient_registration) do
          create(:transient_registration,
                 :has_required_data,
                 :has_conviction_search_result,
                 :has_key_people,
                 :has_paid_balance,
                 workflow_state: "worldpay_form")
        end

        it "changes to :payment_summary_form after the 'back' event" do
          expect(transient_registration).to transition_from(:worldpay_form).to(:payment_summary_form).on_event(:back)
        end

        context "when a conviction check is not required" do
          before do
            allow(transient_registration).to receive(:conviction_check_required?).and_return(false)
          end

          context "when there is no pending WorldPay payment" do
            before do
              allow(transient_registration).to receive(:pending_worldpay_payment?).and_return(false)
            end

            it "does not send a confirmation email after the 'next' event" do
              old_emails_sent_count = ActionMailer::Base.deliveries.count
              transient_registration.next!
              expect(ActionMailer::Base.deliveries.count).to eq(old_emails_sent_count)
            end
          end

          context "when there is a pending WorldPay payment" do
            before do
              allow(transient_registration).to receive(:pending_worldpay_payment?).and_return(true)
            end

            it "changes to :renewal_received_form after the 'next' event" do
              expect(transient_registration).to transition_from(:worldpay_form).to(:renewal_received_form).on_event(:next)
            end

            it "sends a confirmation email after the 'next' event" do
              old_emails_sent_count = ActionMailer::Base.deliveries.count
              transient_registration.next!
              expect(ActionMailer::Base.deliveries.count).to eq(old_emails_sent_count + 1)
            end
          end
        end

        context "when a conviction check is required" do
          before do
            allow(transient_registration).to receive(:conviction_check_required?).and_return(true)
          end

          it "changes to :renewal_received_form after the 'next' event" do
            expect(transient_registration).to transition_from(:worldpay_form).to(:renewal_received_form).on_event(:next)
          end

          it "sends a confirmation email after the 'next' event" do
            old_emails_sent_count = ActionMailer::Base.deliveries.count
            transient_registration.next!
            expect(ActionMailer::Base.deliveries.count).to eq(old_emails_sent_count + 1)
          end
        end
      end
    end
  end
end
