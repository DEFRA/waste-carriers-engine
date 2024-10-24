# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe BuildOrderCopyCardsFinanceDetailsService do
    describe ".run" do
      subject(:run_service) { described_class.run(transient_registration:, payment_method:, cards_count:) }

      let(:payment_method) { :govpay }
      let(:transient_registration) do
        build(
          :transient_registration,
          contact_email: "user@example.com",
          tier: "UPPER",
          finance_details: build(:finance_details)
        )
      end
      let(:finance_details) { transient_registration.finance_details }
      let(:order) { finance_details.orders.last }
      let(:cards_count) { 2 }

      before { allow(Rails.configuration).to receive(:card_charge).and_return(1_000) }

      it_behaves_like "build finance details"

      it "includes a copy cards item" do
        run_service
        matching_item = order[:order_items].find { |item| item["type"] == OrderItem::TYPES[:copy_cards] }
        expect(matching_item).not_to be_nil
      end

      it "has the correct total_amount" do
        run_service
        expect(order.total_amount).to eq(2_000)
      end

      it "has the correct description" do
        run_service
        expect(order.description).to eq("2 registration cards")
      end
    end
  end
end
