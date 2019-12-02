# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe TransientRegistration, type: :model do
    let(:transient_registration) { build(:transient_registration, :has_required_data) }

    describe "#set_metadata_route" do
      it "updates the transient registration's metadata route" do
        metadata_route = double(:metadata_route)

        expect(Rails.configuration).to receive(:metadata_route).and_return(metadata_route)

        expect(transient_registration.metaData).to receive(:route=).with(metadata_route)
        expect(transient_registration).to receive(:save)

        transient_registration.set_metadata_route
      end
    end

    describe "search" do
      it_should_behave_like "Search scopes",
                            record_class: WasteCarriersEngine::TransientRegistration,
                            factory: :transient_registration
    end

    describe "registration attributes" do
      it_should_behave_like "Can have registration attributes",
                            factory: :transient_registration
    end

    describe "conviction scopes" do
      it_should_behave_like "Can filter conviction status"
    end

    describe "#rejected_conviction_checks?" do
      before do
        allow(transient_registration).to receive(:conviction_sign_offs).and_return(conviction_sign_offs)
      end

      context "when there are no conviction sign offs" do
        let(:conviction_sign_offs) { nil }

        it "return false" do
          expect(transient_registration.rejected_conviction_checks?).to be_falsey
        end
      end

      context "when there are conviction sign offs" do
        let(:conviction_sign_off) { double(:conviction_sign_off, rejected?: rejected) }
        let(:conviction_sign_offs) { [double, conviction_sign_off] }

        context "when the last conviction sign off status is rejected" do
          let(:rejected) { true }

          it "returns true" do
            expect(transient_registration.rejected_conviction_checks?).to be_truthy
          end
        end

        context "when the last conviction sign off status is not rejected" do
          let(:rejected) { false }

          it "returns false" do
            expect(transient_registration.rejected_conviction_checks?).to be_falsey
          end
        end
      end
    end

    describe "#pending_payment?" do
      before do
        allow(transient_registration).to receive(:unpaid_balance?).and_return(unpaid_balance)
      end

      context "when there is no unpaid balance" do
        let(:unpaid_balance) { false }

        it "returns false" do
          expect(transient_registration.pending_payment?).to eq(false)
        end
      end

      context "when there is an unpaid balance" do
        let(:unpaid_balance) { true }

        it "returns true" do
          expect(transient_registration.pending_payment?).to eq(true)
        end
      end
    end

    describe "#pending_worldpay_payment?" do
      context "when the renewal has an order" do
        before do
          transient_registration.finance_details = build(:finance_details, :has_order)
        end

        context "when the order's world_pay_status is pending" do
          before do
            allow(Order).to receive(:valid_world_pay_status?).and_return(true)
          end

          it "returns true" do
            expect(transient_registration.pending_worldpay_payment?).to eq(true)
          end
        end

        context "when the order's world_pay_status is not pending" do
          before do
            allow(Order).to receive(:valid_world_pay_status?).and_return(false)
          end

          it "returns false" do
            expect(transient_registration.pending_worldpay_payment?).to eq(false)
          end
        end
      end

      context "when the renewal has no order" do
        before do
          transient_registration.finance_details = build(:finance_details)
        end

        it "returns false" do
          expect(transient_registration.pending_worldpay_payment?).to eq(false)
        end
      end
    end

    describe "#pending_manual_conviction_check?" do
      context "when conviction_check_required? is false" do
        before do
          allow(transient_registration).to receive(:conviction_check_required?).and_return(false)
        end

        it "returns false" do
          expect(transient_registration.pending_manual_conviction_check?).to eq(false)
        end
      end

      context "when conviction_check_required? is true" do
        before do
          allow(transient_registration).to receive(:conviction_check_required?).and_return(true)
        end

        it "returns true" do
          expect(transient_registration.pending_manual_conviction_check?).to eq(true)
        end
      end
    end
  end
end
