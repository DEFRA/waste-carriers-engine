# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe TransientRegistration, type: :model do
    let(:transient_registration) { build(:transient_registration, :has_required_data) }

    describe "#set_metadata_route" do
      it "updates the transient registration's metadata route" do
        allow_message_expectations_on_nil

        metadata_route = double(:metadata_route)

        expect(Rails.configuration).to receive(:metadata_route).and_return(metadata_route)

        expect(transient_registration.metaData).to receive(:route=).with(metadata_route)
        expect(transient_registration).to receive(:save)

        transient_registration.set_metadata_route
      end
    end

    describe "#update_created_at" do
      context "when a new transient registration is created" do
        it "updates the transient registration's created_at" do
          time = double(:time)

          expect(Time).to receive(:current).and_return(time)

          expect(transient_registration).to receive(:created_at=).with(time)

          transient_registration.save
        end
      end
    end

    describe "search" do
      it_should_behave_like "Search scopes",
                            record_class: WasteCarriersEngine::TransientRegistration,
                            factory: :transient_registration
    end

    describe "secure token" do
      it_should_behave_like "Having a secure token"
    end

    describe "registration attributes" do
      it_should_behave_like "Can have registration attributes",
                            factory: :transient_registration
    end

    describe "entity_display names" do
      it_should_behave_like "Can present entity display name",
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

    describe "#pending_online_payment?" do
      context "when the renewal has an order" do
        before do
          transient_registration.finance_details = build(:finance_details, :has_order)
        end

        context "when the order's world_pay_status is pending" do
          before do
            allow(WorldpayValidatorService).to receive(:valid_world_pay_status?).and_return(true)
          end

          it "returns true" do
            expect(transient_registration.pending_online_payment?).to eq(true)
          end
        end

        context "when the order's world_pay_status is not pending" do
          before do
            allow(WorldpayValidatorService).to receive(:valid_world_pay_status?).and_return(false)
          end

          it "returns false" do
            expect(transient_registration.pending_online_payment?).to eq(false)
          end
        end
      end

      context "when the renewal has no order" do
        before do
          transient_registration.finance_details = build(:finance_details)
        end

        it "returns false" do
          expect(transient_registration.pending_online_payment?).to eq(false)
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

    describe "#business_type_change_valid?" do
      let(:renewing_registration) { build(:renewing_registration) }
      let(:business_types) { %w[authority charity limitedCompany limitedLiabilityPartnership localAuthority overseas partnership publicBody soleTrader] }
      let(:valid_changes) do
        {
          "authority" => %w[overseas localAuthority],
          "charity" => %w[overseas],
          "limitedCompany" => %w[overseas limitedLiabilityPartnership],
          "limitedLiabilityPartnership" => %w[overseas],
          "localAuthority" => %w[overseas],
          "partnership" => %w[overseas],
          "publicBody" => %w[overseas localAuthority],
          "soleTrader" => %w[overseas]
        }
      end

      context "valid change" do

        it "allows all valid changes" do
          valid_changes.each do |old_type, new_types|
            allow_any_instance_of(Registration).to receive(:business_type).and_return(old_type)

            new_types.each do |new_type|
              allow(renewing_registration).to receive(:business_type).and_return(new_type)

              expect(renewing_registration.business_type_change_valid?).to be_truthy
            end
          end
        end
      end

      context "invalid change" do
        it "does not allow invalid changes" do
          business_types.each do |old_type|
            allow_any_instance_of(Registration).to receive(:business_type).and_return(old_type)

            business_types.each do |new_type|
              next if old_type == new_type
              next if valid_changes[old_type]&.include?(new_type)

              allow(renewing_registration).to receive(:business_type).and_return(new_type)

              expect(renewing_registration.business_type_change_valid?).not_to be_truthy
            end
          end
        end
      end
    end

    describe "#registration" do
      it "raises a not implemented error" do
        expect { transient_registration.registration }.to raise_error(NotImplementedError)
      end
    end

    describe "#next_state!" do
      let(:new_registration) { build(:new_registration, :has_required_data) }

      subject { new_registration.next_state! }

      context "with no available next state" do
        before { new_registration.workflow_state = "registration_completed_form" }

        it "does not change the state" do
          expect { subject }.not_to change { new_registration.workflow_state }
        end

        it "does not add to workflow history" do
          expect { subject }.not_to change { new_registration.workflow_history }
        end
      end

      context "with an invalid state" do
        before { new_registration.workflow_state = "not_valid" }

        it "does not change the state" do
          expect { subject }.not_to change { new_registration.workflow_state }
        end

        it "does not add to workflow history" do
          expect { subject }.not_to change { new_registration.workflow_history }
        end
      end

      context "with a valid state" do
        before { new_registration.workflow_state = "location_form" }

        it "changes the state" do
          expect { subject }.to change { new_registration.workflow_state }.to("business_type_form")
        end

        it "adds to workflow history" do
          expect { subject }.to change { new_registration.workflow_history.length }.from(0).to(1)
        end

        it "adds the previous state to workflow history" do
          expect { subject }.to change { new_registration.workflow_history }.to(["location_form"])
        end
      end
    end

    describe "#previous_valid_state!" do
      let(:new_registration) { build(:new_registration, :has_required_data) }

      subject { new_registration.previous_valid_state! }

      context "with no workflow history" do
        before { new_registration.workflow_history = [] }
        before { new_registration.workflow_state = "location_form" }

        it "uses the default state" do
          expect { subject }.to change { new_registration.workflow_state }.to("start_form")
        end

        it "does not modify workflow history" do
          expect { subject }.not_to change { new_registration.workflow_history }
        end
      end

      context "with partially invalid workflow history" do
        before { new_registration.workflow_history = %w[another_form location_form not_valid] }

        it "skips the invalid state" do
          expect { subject }.to change { new_registration.workflow_state }.to("location_form")
        end

        it "deletes multiple items workflow history" do
          expect { subject }.to change { new_registration.workflow_history.length }.by(-2)
        end
      end

      context "with fully invalid workflow history" do
        before do
          new_registration.workflow_state = "location_form"
          new_registration.workflow_history = %w[no_start_form not_valid]
        end

        it "uses the default state" do
          expect { subject }.to change { new_registration.workflow_state }.to("start_form")
        end

        it "deletes all items from workflow history" do
          expect { subject }.to change { new_registration.workflow_history.length }.to(0)
        end
      end

      context "with valid workflow history" do
        before do
          new_registration.workflow_history = %w[start_form location_form]
          new_registration.workflow_state = "business_type_form"
        end

        it "changes the state" do
          expect { subject }.to change { new_registration.workflow_state }.to("location_form")
        end

        it "deletes from workflow history" do
          expect { subject }.to change { new_registration.workflow_history.length }.by(-1)
        end
      end

      context "when the current state is also in the workflow history" do
        before do
          new_registration.workflow_history = %w[start_form location_form location_form]
          new_registration.workflow_state = "location_form"
        end

        it "skips the duplicated state" do
          expect { subject }.to change { new_registration.workflow_state }.to("start_form")
        end

        it "deletes from workflow history" do
          expect { subject }.to change { new_registration.workflow_history.length }.to(0)
        end
      end
    end
  end
end
