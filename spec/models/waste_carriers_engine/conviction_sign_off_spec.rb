require "rails_helper"

module WasteCarriersEngine
  RSpec.describe ConvictionSignOff, type: :model do
    let(:transient_registration) { build(:transient_registration, :requires_conviction_check) }
    let(:conviction_sign_off) { transient_registration.conviction_sign_offs.first }

    describe "#approve" do
      context "when a conviction_sign_off is approved" do
        let(:user) { build(:user) }

        before do
          conviction_sign_off.approve(user)
        end

        it "updates confirmed" do
          expect(conviction_sign_off.confirmed).to eq("yes")
        end

        it "updates confirmed_at" do
          expect(conviction_sign_off.confirmed_at).to be_a(DateTime)
        end

        it "updates confirmed_by" do
          expect(conviction_sign_off.confirmed_by).to eq(user.email)
        end
      end
    end

    describe "#workflow_state" do
      context "when a conviction_sign_off is created" do
        it "has the workflow_state 'possible_match'" do
          expect(conviction_sign_off.workflow_state).to eq("possible_match")
        end
      end

      context "when the conviction_sign_off workflow_state is 'possible_match'" do
        let(:conviction_sign_off) { build(:conviction_sign_off, :possible_match) }

        it "can begin checks" do
          expect(conviction_sign_off).to allow_event :begin_checks
        end

        it "can be signed off" do
          expect(conviction_sign_off).to allow_event :sign_off
        end

        it "can be rejected" do
          expect(conviction_sign_off).to allow_event :reject
        end
      end

      context "when the conviction_sign_off workflow_state is 'checks_in_progress'" do
        let(:conviction_sign_off) { build(:conviction_sign_off, :checks_in_progress) }

        it "cannot begin checks" do
          expect(conviction_sign_off).to_not allow_event :begin_checks
        end

        it "can be signed off" do
          expect(conviction_sign_off).to allow_event :sign_off
        end

        it "can be rejected" do
          expect(conviction_sign_off).to allow_event :reject
        end
      end

      context "when the conviction_sign_off workflow_state is 'approved'" do
        let(:conviction_sign_off) { build(:conviction_sign_off, :approved) }

        it "cannot begin checks" do
          expect(conviction_sign_off).to_not allow_event :begin_checks
        end

        it "cannot be signed off" do
          expect(conviction_sign_off).to_not allow_event :sign_off
        end

        it "cannot be rejected" do
          expect(conviction_sign_off).to_not allow_event :reject
        end
      end

      context "when the conviction_sign_off workflow_state is 'rejected'" do
        let(:conviction_sign_off) { build(:conviction_sign_off, :rejected) }

        it "cannot begin checks" do
          expect(conviction_sign_off).to_not allow_event :begin_checks
        end

        it "cannot be signed off" do
          expect(conviction_sign_off).to_not allow_event :sign_off
        end

        it "cannot be rejected" do
          expect(conviction_sign_off).to_not allow_event :reject
        end
      end
    end
  end
end
