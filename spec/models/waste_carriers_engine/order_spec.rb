# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe Order do
    before do
      allow(Rails.configuration).to receive(:renewal_charge).and_return(10_000)
      allow(Rails.configuration).to receive(:type_change_charge).and_return(2_500)
      allow(Rails.configuration).to receive(:card_charge).and_return(1_000)
      allow(Rails.configuration).to receive(:worldpay_merchantcode).and_return("MERCHANTCODE")
    end

    let(:transient_registration) { create(:renewing_registration, :has_required_data, temp_cards: 0) }
    let(:current_user) { build(:user) }

    describe "new_order" do
      let(:order) { described_class.new_order(transient_registration, payment_method, current_user.email) }
      let(:payment_method) { :worldpay }

      it "has a valid order_id" do
        Timecop.freeze(Time.new(2018, 1, 1)) do
          expect(order[:order_id]).to eq("1514764800")
        end
      end

      it "has a matching order_id and order_code" do
        expect(order[:order_id]).to eq(order[:order_code])
      end

      it "includes 1 renewal item" do
        matching_item = order[:order_items].find { |item| item[:type] == OrderItem::TYPES[:renew] }
        expect(matching_item).not_to be_nil
      end

      it "has the correct total_amount" do
        expect(order.total_amount).to eq(10_000)
      end

      it "has the correct updated_by_user" do
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

      it "has the correct description" do
        expect(order.description).to eq("Renewal of registration")
      end

      context "when the registration type has not changed" do
        it "does not include a type change item" do
          matching_item = order[:order_items].find { |item| item[:type] == OrderItem::TYPES[:edit] }
          expect(matching_item).to be_nil
        end
      end

      context "when the registration type has changed" do
        before do
          transient_registration.registration_type = "broker_dealer"
        end

        it "includes a type change item" do
          matching_item = order[:order_items].find { |item| item[:type] == OrderItem::TYPES[:edit] }
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
        before do
          transient_registration.temp_cards = 0
        end

        it "does not include a copy cards item" do
          matching_item = order[:order_items].find { |item| item[:type] == OrderItem::TYPES[:copy_cards] }
          expect(matching_item).to be_nil
        end
      end

      context "when temp_cards is not present" do
        before do
          transient_registration.temp_cards = nil
        end

        it "does not include a copy cards item" do
          matching_item = order[:order_items].find { |item| item[:type] == OrderItem::TYPES[:copy_cards] }
          expect(matching_item).to be_nil
        end
      end

      context "when there are copy cards" do
        before do
          transient_registration.temp_cards = 3
        end

        it "includes a copy cards item" do
          matching_item = order[:order_items].find { |item| item[:type] == OrderItem::TYPES[:copy_cards] }
          expect(matching_item).not_to be_nil
        end

        it "has the correct total_amount" do
          expect(order.total_amount).to eq(13_000)
        end

        it "has the correct description" do
          expect(order.description).to eq("Renewal of registration, plus 3 registration cards")
        end
      end

      context "when it is a Worldpay order" do
        it "has the correct payment_method" do
          expect(order.payment_method).to eq("ONLINE")
        end

        it "has the correct merchant_id" do
          expect(order.merchant_id).to eq("MERCHANTCODE")
        end

        it "has the correct world_pay_status" do
          expect(order.world_pay_status).to eq("IN_PROGRESS")
        end
      end

      context "when it is a govpay order" do
        let(:payment_method) { :govpay }

        it "has the correct payment_method" do
          expect(order.payment_method).to eq("ONLINE")
        end

        it "has the correct world_pay_status" do
          expect(order.govpay_status).to eq("IN_PROGRESS")
        end
      end

      context "when it is a bank transfer order" do
        let(:order) { described_class.new_order(transient_registration, :bank_transfer, current_user) }

        it "has the correct payment_method" do
          expect(order.payment_method).to eq("OFFLINE")
        end

        it "has the correct merchant_id" do
          expect(order.merchant_id).to be_nil
        end

        it "has the correct world_pay_status" do
          expect(order.world_pay_status).to be_nil
        end
      end
    end

    describe "update_after_online_payment" do
      let(:finance_details) { transient_registration.prepare_for_payment(:worldpay, current_user) }
      let(:order) { finance_details.orders.first }

      it "copies the worldpay status to the order" do
        order.update_after_online_payment("AUTHORISED")
        expect(order.world_pay_status).to eq("AUTHORISED")
      end

      it "updates the date_last_updated" do
        Timecop.freeze(Time.new(2004, 8, 15, 16, 23, 42)) do
          # Wipe the date first so we know the value has been added
          order.update_attributes(date_last_updated: nil)

          order.update_after_online_payment("AUTHORISED")
          expect(order.date_last_updated).to eq(Time.new(2004, 8, 15, 16, 23, 42))
        end
      end
    end

    describe "#payment_uuid" do
      let(:transient_registration) { build(:renewing_registration, :has_required_data, :has_finance_details) }
      let(:order) { described_class.new(finance_details: transient_registration.finance_details) }

      context "with no pre-existing uuid" do
        it "generates and saves a uuid" do
          expect(order[:payment_uuid]).to be_nil
          expect(order.payment_uuid).to be_present
          expect(order[:payment_uuid]).to be_present
        end
      end

      context "with a pre-existing uuid" do
        it "returns the existing uuid" do
          uuid = order.payment_uuid
          expect(order.payment_uuid).to eq uuid
        end
      end
    end
  end
end
