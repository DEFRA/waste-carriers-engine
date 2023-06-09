# frozen_string_literal: true

require "rails_helper"

RSpec.describe WasteCarriersEngine::VerifyIfMobileService do
  describe ".run" do
    valid_mobile_numbers = ["07123456789", "07223456789", "07323456789", "07423456789",
                            "07523456789", "0762423456789", "07723456789", "07823456789",
                            "07923456789", "00447723456789", "+447723456789"]

    valid_mobile_numbers.each do |number|
      it "returns true for valid mobile number #{number}" do
        expect(described_class.run(phone_number: number)).to be true
      end
    end

    context "with non-mobile numbers" do
      it "returns false for numbers starting with 070" do
        expect(described_class.run(phone_number: "07023456789")).to be false
      end

      it "returns false for numbers starting with 076 (but not followed by 24)" do
        expect(described_class.run(phone_number: "07623456789")).to be false
      end

      it "returns false for landline numbers" do
        expect(described_class.run(phone_number: "013123456789")).to be false
      end

      it "returns false for numbers starting with 0845" do
        expect(described_class.run(phone_number: "084512345678")).to be false
      end

      it "returns false for corporate numbers starting with 055" do
        expect(described_class.run(phone_number: "05523456789")).to be false
      end
    end

    it "returns false when phone number is nil" do
      expect(described_class.run(phone_number: nil)).to be false
    end
  end
end
