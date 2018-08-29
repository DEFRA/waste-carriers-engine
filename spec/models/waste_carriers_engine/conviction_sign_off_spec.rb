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
  end
end
