# frozen_string_literal: true

RSpec.shared_examples "Can have registration attributes" do
  describe "#conviction_check_approved?" do
    context "when there are no conviction_sign_offs" do
      before do
        transient_registration.conviction_sign_offs = nil
      end

      it "returns false" do
        expect(transient_registration.conviction_check_approved?).to eq(false)
      end
    end

    context "when there is a conviction_sign_off" do
      before do
        transient_registration.conviction_sign_offs = [build(:conviction_sign_off)]
      end

      context "when confirmed is no" do
        before do
          transient_registration.conviction_sign_offs.first.confirmed = "no"
        end

        it "returns false" do
          expect(transient_registration.conviction_check_approved?).to eq(false)
        end
      end

      context "when confirmed is yes" do
        before do
          transient_registration.conviction_sign_offs.first.confirmed = "yes"
        end

        it "returns true" do
          expect(transient_registration.conviction_check_approved?).to eq(true)
        end
      end
    end
  end
end
