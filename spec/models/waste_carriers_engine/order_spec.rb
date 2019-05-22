# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe Order, type: :model do
    before do
      allow(Rails.configuration).to receive(:renewal_charge).and_return(10_000)
      allow(Rails.configuration).to receive(:type_change_charge).and_return(2_500)
      allow(Rails.configuration).to receive(:card_charge).and_return(1_000)
      allow(Rails.configuration).to receive(:worldpay_merchantcode).and_return("MERCHANTCODE")
    end

    let(:transient_registration) { create(:transient_registration, :has_required_data, temp_cards: 0) }
    let(:current_user) { build(:user) }

    describe "new_order" do
      let(:order) { Order.new_order(transient_registration, :worldpay, current_user) }

      it "should have a valid order_id" do
        Timecop.freeze(Time.new(2018, 1, 1)) do
          expect(order[:order_id]).to eq("1514764800")
        end
      end

      it "should have a matching order_id and order_code" do
        expect(order[:order_id]).to eq(order[:order_code])
      end

      it "should include 1 renewal item" do
        matching_item = order[:order_items].find { |item| item[:type] == OrderItem::TYPES[:renew] }
        expect(matching_item).to_not be_nil
      end

      it "should have the correct total_amount" do
        expect(order.total_amount).to eq(10_000)
      end

      it "should have the correct updated_by_user" do
        expect(order.updated_by_user).to eq(current_user.email)
      end

      it "updates the date_created" do
        Timecop.freeze(Time.new(2004, 8, 15, 16, 23, 42)) do
          expect(order.date_created).to eq(Time.new(2004, 8, 15, 16, 23, 42))
        end
      end

      it "updates the date_last_updated" do
        Timecop.freeze(Time.new(2004, 8, 15, 16, 23, 42)) do
          expect(order.date_last_updated).to eq(Time.new(2004, 8, 15, 16, 23, 42))
        end
      end

      it "should have the correct description" do
        expect(order.description).to eq("Renewal of registration")
      end

      context "when the registration type has not changed" do
        it "should not include a type change item" do
          matching_item = order[:order_items].find { |item| item[:type] == OrderItem::TYPES[:edit] }
          expect(matching_item).to be_nil
        end
      end

      context "when the registration type has changed" do
        before do
          transient_registration.registration_type = "broker_dealer"
        end

        it "should include a type change item" do
          matching_item = order[:order_items].find { |item| item[:type] == OrderItem::TYPES[:edit] }
          expect(matching_item).to_not be_nil
        end

        it "should have the correct total_amount" do
          expect(order.total_amount).to eq(12_500)
        end

        it "should have the correct description" do
          expect(order.description).to eq("Renewal of registration, plus changing carrier type during renewal")
        end
      end

      context "when temp_cards is 0" do
        before do
          transient_registration.temp_cards = 0
        end

        it "should not include a copy cards item" do
          matching_item = order[:order_items].find { |item| item[:type] == OrderItem::TYPES[:copy_cards] }
          expect(matching_item).to be_nil
        end
      end

      context "when temp_cards is not present" do
        before do
          transient_registration.temp_cards = nil
        end

        it "should not include a copy cards item" do
          matching_item = order[:order_items].find { |item| item[:type] == OrderItem::TYPES[:copy_cards] }
          expect(matching_item).to be_nil
        end
      end

      context "when there are copy cards" do
        before do
          transient_registration.temp_cards = 3
        end

        it "should include a copy cards item" do
          matching_item = order[:order_items].find { |item| item[:type] == OrderItem::TYPES[:copy_cards] }
          expect(matching_item).to_not be_nil
        end

        it "should have the correct total_amount" do
          expect(order.total_amount).to eq(13_000)
        end

        it "should have the correct description" do
          expect(order.description).to eq("Renewal of registration, plus 3 registration cards")
        end
      end

      context "when it is a Worldpay order" do
        it "should have the correct payment_method" do
          expect(order.payment_method).to eq("ONLINE")
        end

        it "should have the correct merchant_id" do
          expect(order.merchant_id).to eq("MERCHANTCODE")
        end

        it "should have the correct world_pay_status" do
          expect(order.world_pay_status).to eq("IN_PROGRESS")
        end
      end

      context "when it is a bank transfer order" do
        let(:order) { Order.new_order(transient_registration, :bank_transfer, current_user) }

        it "should have the correct payment_method" do
          expect(order.payment_method).to eq("OFFLINE")
        end

        it "should have the correct merchant_id" do
          expect(order.merchant_id).to eq(nil)
        end

        it "should have the correct world_pay_status" do
          expect(order.world_pay_status).to eq(nil)
        end
      end
    end

    describe "update_after_worldpay" do
      let(:finance_details) { FinanceDetails.new_finance_details(transient_registration, :worldpay, current_user) }
      let(:order) { finance_details.orders.first }

      it "copies the worldpay status to the order" do
        order.update_after_worldpay("AUTHORISED")
        expect(order.world_pay_status).to eq("AUTHORISED")
      end

      it "updates the date_last_updated" do
        Timecop.freeze(Time.new(2004, 8, 15, 16, 23, 42)) do
          # Wipe the date first so we know the value has been added
          order.update_attributes(date_last_updated: nil)

          order.update_after_worldpay("AUTHORISED")
          expect(order.date_last_updated).to eq(Time.new(2004, 8, 15, 16, 23, 42))
        end
      end
    end

    describe "valid_world_pay_status?" do
      it "returns true when the status matches the values for the response type" do
        expect(Order.valid_world_pay_status?(:success, "AUTHORISED")).to eq(true)
      end

      it "returns false when the status does not match the values for the response type" do
        expect(Order.valid_world_pay_status?(:success, "FOO")).to eq(false)
      end
    end
  end
end
