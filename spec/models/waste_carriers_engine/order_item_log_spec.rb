# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe OrderItemLog do
    describe "#initialize" do

      context "with a new registration" do
        let(:registration) { create(:registration, :has_required_data, :has_copy_cards_order) }
        let(:order) { registration.finance_details.orders[0] }
        let(:registration_order_item) { order.order_items[0] }

        subject(:order_item_log) { described_class.create_from_order_item(registration_order_item) }

        it "persists the order item log" do
          expect { order_item_log }.to change(described_class, :count).from(0).to(1)
        end

        it "saves the registration id" do
          expect(order_item_log.registration_id).to eq registration.id
        end

        it "saves the registration activation date" do
          expect(order_item_log.activated_at).to eq registration.metaData.dateActivated
        end

        it "saves the order id" do
          expect(order_item_log.order_id).to eq order.id
        end

        it "is not exported by default" do
          expect(order_item_log.exported).to be false
        end

        it "copies the OrderItem attributes" do
          expect(order_item_log.order_item_id).to eq registration_order_item.id
          expect(order_item_log.type).to eq registration_order_item.type
          expect(order_item_log.quantity).to eq registration_order_item.quantity
        end
      end
    end

    describe ".create_from_registration" do
      let(:registration) { create(:registration, :has_required_data, :has_copy_cards_order) }

      subject(:order_item_log) { described_class.create_from_registration(registration) }
      before do
        3.times { registration.finance_details.orders << build(:order, :has_copy_cards_item) }
      end

      context "with a new registration" do
        it "creates the correct number of order item logs" do
          expect { order_item_log }.to change(described_class, :count)
            .from(0)
            .to(order_item_count(registration))
        end
      end

      context "with a registration with previously logged order items" do
        let(:new_order) { build(:order, :has_copy_cards_item) }

        before do
          Timecop.freeze(1.month.ago) do
            described_class.create_from_registration(registration)
          end
        end

        it "adds only the new order item logs" do
          previous_count = order_item_count(registration)
          registration.finance_details.orders << new_order
          expect { order_item_log }.to change(described_class, :count)
            .from(previous_count)
            .to(order_item_count(registration))
        end

      end

      context "with an order activation time value" do
        it "sets the activation time to the provided time" do
          described_class.create_from_registration(registration, DateTime.now)
          expect(described_class.first.activated_at.to_time).to be_within(1.second).of(Time.now)
        end
      end
    end

    describe "#active_registration?" do
      let(:order_item_log) { build(:order_item_log, registration: registration) }

      subject(:is_active) { order_item_log.active_registration? }

      context "with an active registration" do
        let(:registration) { build(:registration, :is_active) }

        it { expect(is_active).to be_truthy }
      end

      context "with an expired registration" do
        let(:registration) { build(:registration, :is_expired) }

        it { expect(is_active).to be_falsey }
      end
    end

    def order_item_count(registration)
      registration.finance_details.orders.sum { |o| o.order_items.length }
    end
  end
end
