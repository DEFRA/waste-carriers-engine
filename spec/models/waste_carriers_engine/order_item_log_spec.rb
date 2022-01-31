# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe OrderItemLog, type: :model do
    describe "initialize" do
      let(:registration) { build(:registration, :has_required_data, :has_copy_cards_order) }
      let(:order) { registration.finance_details.orders[0] }
      let(:registration_order_item) { order.order_items[0] }

      subject { described_class.create!(registration_order_item) }

      it "persists the order item log" do
        expect { subject }.to change { OrderItemLog.count }.from(0).to(1)
      end

      it "saves the registration id" do
        expect(subject.registration_id).to eq registration.id
      end

      it "saves the registration activation date" do
        expect(subject.activated_at).to eq registration.metaData.dateActivated
      end

      it "saves the order id" do
        expect(subject.order_id).to eq order.id
      end

      it "copies the OrderItem attributes" do
        expect(subject.order_item_id).to eq registration_order_item.id
        expect(subject.type).to eq registration_order_item.type
      end

    end
  end
end
