# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe BuildRenewalFinanceDetailsService do
    describe ".run" do
      subject(:run_service) { described_class.run(transient_registration:, payment_method:) }

      let(:payment_method) { :govpay }
      let(:transient_registration) do
        build(
          :renewing_registration,
          contact_email: "user@example.com",
          temp_cards:,
          tier: "UPPER",
          finance_details: build(:finance_details)
        )
      end
      let(:finance_details) { transient_registration.finance_details }
      let(:order) { finance_details.orders.last }
      let(:temp_cards) { nil }

      before do
        allow(Rails.configuration).to receive_messages(renewal_charge: 10_000, type_change_charge: 2_500, card_charge: 1_000)
      end

      it_behaves_like "build finance details"

      it "has the correct description" do
        run_service
        expect(order.description).to eq("Renewal of registration")
      end

      it "includes 1 renewal item" do
        run_service
        matching_item = order[:order_items].find { |item| item["type"] == OrderItem::TYPES[:renew] }
        expect(matching_item).not_to be_nil
      end

      it "has the correct total_amount" do
        run_service
        expect(order.total_amount).to eq(10_000)
      end

      context "when the registration type has not changed" do
        it "does not include a type change item" do
          run_service
          matching_item = order[:order_items].find { |item| item["type"] == OrderItem::TYPES[:edit] }
          expect(matching_item).to be_nil
        end
      end

      context "when the registration type has changed" do
        before do
          transient_registration.registration_type = "broker_dealer"
          run_service
        end

        it "includes a type change item" do
          matching_item = order[:order_items].find { |item| item["type"] == OrderItem::TYPES[:edit] }
          expect(matching_item).not_to be_nil
        end

        it "has the correct total_amount" do
          expect(order.total_amount).to eq(12_500)
        end

        it "has the correct description" do
          expect(order.description).to eq("Renewal of registration, plus changing carrier type")
        end
      end

      context "when temp_cards is 0" do
        before { transient_registration.temp_cards = 0 }

        it "does not include a copy cards item" do
          run_service
          matching_item = order[:order_items].find { |item| item["type"] == OrderItem::TYPES[:copy_cards] }
          expect(matching_item).to be_nil
        end
      end

      context "when temp_cards is not present" do
        before { transient_registration.temp_cards = nil }

        it "does not include a copy cards item" do
          run_service
          matching_item = order[:order_items].find { |item| item["type"] == OrderItem::TYPES[:copy_cards] }
          expect(matching_item).to be_nil
        end
      end

      context "when there are copy cards" do
        let(:temp_cards) { 3 }

        before { run_service }

        it "includes a copy cards item" do
          matching_item = order[:order_items].find { |item| item["type"] == OrderItem::TYPES[:copy_cards] }
          expect(matching_item).not_to be_nil
        end

        it "has the correct total_amount" do
          expect(order.total_amount).to eq(13_000)
        end

        it "has the correct description" do
          expect(order.description).to eq("Renewal of registration, plus 3 registration cards")
        end
      end
    end
  end
end
