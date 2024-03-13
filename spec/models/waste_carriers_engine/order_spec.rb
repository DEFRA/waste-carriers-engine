# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe Order do
    before do
      allow(Rails.configuration).to receive(:renewal_charge).and_return(10_000)
      allow(Rails.configuration).to receive(:type_change_charge).and_return(2_500)
      allow(Rails.configuration).to receive(:card_charge).and_return(1_000)
    end

    let(:transient_registration) { create(:renewing_registration, :has_required_data, temp_cards: 0) }
    let(:current_user) { build(:user) }

    describe "update_after_online_payment" do
      let(:finance_details) { transient_registration.prepare_for_payment(:govpay, current_user) }
      let(:order) { finance_details.orders.first }

      it "copies the govpay status to the order" do
        order.update_after_online_payment("created")
        expect(order.govpay_status).to eq("created")
      end

      it "updates the date_last_updated" do
        Timecop.freeze(Time.new(2004, 8, 15, 16, 23, 42)) do
          # Wipe the date first so we know the value has been added
          order.update_attributes(date_last_updated: nil)

          order.update_after_online_payment("created")
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
