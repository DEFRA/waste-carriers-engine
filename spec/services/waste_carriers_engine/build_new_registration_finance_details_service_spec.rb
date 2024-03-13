# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe BuildNewRegistrationFinanceDetailsService do
    describe ".run" do
      subject(:run_service) { described_class.run(transient_registration:, payment_method:, user: current_user) }

      let(:payment_method) { :govpay }
      let(:transient_registration) do
        build(
          :new_registration,
          contact_email: "user@example.com",
          temp_cards: 2,
          tier: "UPPER",
          finance_details: build(:finance_details)
        )
      end
      let(:finance_details) { transient_registration.finance_details }
      let(:order) { finance_details.orders.last }
      let(:current_user) { build(:user) }

      it_behaves_like "build finance details"

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
        before do
          transient_registration.temp_cards = 3
          run_service
        end

        it "includes a copy cards item" do
          matching_item = order[:order_items].find { |item| item["type"] == OrderItem::TYPES[:copy_cards] }
          expect(matching_item).not_to be_nil
        end
      end
    end
  end
end
