# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe OrderCopyCardsCompletionService do
    describe ".run" do

      let(:contact_email) { Faker::Internet.email }
      let(:transient_registration) { create(:order_copy_cards_registration, :has_finance_details, contact_email: contact_email) }
      let(:registration) { transient_registration.registration }
      let(:transient_finance_details) { transient_registration.finance_details }

      # Ensure registration activation date is prior to the card order date
      before do
        registration.metaData.dateActivated = 1.month.ago
      end

      RSpec.shared_examples "completes the order" do |notify_email_service|
        it "merges finance details" do
          expect(registration.finance_details).to receive(:update_balance)
          described_class.run(transient_registration)
        end

        it "merges the order" do
          described_class.run(transient_registration)
          expect(registration.finance_details.orders).to include(transient_finance_details.orders[0])
        end

        it "deletes the transient registration" do
          expect(transient_registration).to receive(:delete)
          described_class.run(transient_registration)
        end

        it "saves the registration" do
          expect(registration).to receive(:save!)
          described_class.run(transient_registration)
        end

        context "with a non-assisted-digital email address" do
          let(:contact_email) { Faker::Internet.email }

          it "sends an email using the appropriate service" do
            expect(notify_email_service)
              .to receive(:run)
              .with(registration: registration, order: transient_finance_details.orders[0])
            described_class.run(transient_registration)
          end
        end

        context "when the registration has an AD contact email" do
          let(:contact_email) { WasteCarriersEngine.configuration.assisted_digital_email }

          it "does not send an email" do
            expect(notify_email_service).not_to receive(:run)
          end
        end
      end

      context "when the registration has not been paid in full" do
        before do
          allow(transient_registration).to receive(:unpaid_balance?).and_return(true)
        end

        it_behaves_like "completes the order", Notify::CopyCardsAwaitingPaymentEmailService

        it "does not merge the payment" do
          described_class.run(transient_registration)
          expect(registration.finance_details.payments).not_to include(transient_finance_details.payments[0])
        end

        it "does not create an order item log" do
          expect { described_class.run(transient_registration) }.not_to change { OrderItemLog.count }.from(0)
        end
      end

      context "when the registration has been paid in full" do
        before do
          transient_finance_details.payments << build(:payment, :bank_transfer, amount: 500)
          transient_finance_details.update_balance
        end

        it_behaves_like "completes the order", Notify::CopyCardsOrderCompletedEmailService

        it "merges the payment" do
          described_class.run(transient_registration)
          expect(registration.finance_details.payments).to include(transient_finance_details.payments[0])
        end

        it "creates one or more order item logs" do
          expect { described_class.run(transient_registration) }.to change { OrderItemLog.count }.from(0)
        end

        it "creates order item logs with activated_at set to the current time" do
          described_class.run(transient_registration)
          first_card_order_item = OrderItemLog.where(type: "COPY_CARDS").first
          expect(first_card_order_item.activated_at.to_time).to be_within(1.second).of(Time.now)
        end
      end

    end
  end
end
