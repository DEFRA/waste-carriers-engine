# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe NewRegistration do
    subject(:new_registration) { build(:new_registration) }

    describe "scopes" do
      it_behaves_like "TransientRegistration named scopes"
    end

    describe "#tier_known?" do
      subject(:new_registration) { build(:new_registration, temp_check_your_tier: temp_check_your_tier) }

      context "when the temp_check_your_tier is not populated" do
        let(:temp_check_your_tier) { nil }

        it "returns false" do
          expect(new_registration.tier_known?).to be false
        end
      end

      context "when the temp_check_your_tier is unknown" do
        let(:temp_check_your_tier) { "unknown" }

        it "returns false" do
          expect(new_registration.tier_known?).to be false
        end
      end

      context "when the temp_check_your_tier is not unknown" do
        let(:temp_check_your_tier) { "lower" }

        it "returns true" do
          expect(new_registration.tier_known?).to be true
        end
      end
    end

    describe "#reg_identifier" do
      context "when there is no reg_identifier number persisted in the db yet" do
        it "returns nil" do
          expect(new_registration.reg_identifier).to be_nil
        end
      end

      context "when there is a reg_identifier number persisted in the db" do
        context "when the registration is a lower tier" do
          subject(:new_registration) { build(:new_registration, :lower, reg_identifier: 3) }

          it "returns a CBDL identifier" do
            expect(new_registration.reg_identifier).to eq("CBDL3")
          end
        end

        context "when the registration is an upper tier" do
          subject(:new_registration) { build(:new_registration, :upper, reg_identifier: 3) }

          it "returns a CBDU identifier" do
            expect(new_registration.reg_identifier).to eq("CBDU3")
          end
        end
      end
    end
  end
end
