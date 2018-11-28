# frozen_string_literal: true

RSpec.shared_examples "Can have registration attributes" do
  describe "#charity?" do
    let(:transient_registration) { build(:transient_registration) }

    test_values = {
      charity: true,
      limitedCompany: false
    }

    test_values.each do |business_type, result|
      context "when the 'business_type' is '#{business_type}'" do
        it "returns #{result}" do
          transient_registration.business_type = business_type.to_s
          expect(transient_registration.charity?).to eq(result)
        end
      end
    end
  end

  describe "#company_no_required?" do
    let(:transient_registration) { build(:transient_registration) }

    test_values = {
      limitedCompany: true,
      limitedLiabilityPartnership: true,
      overseas: false
    }

    test_values.each do |business_type, result|
      context "when the 'business_type' is '#{business_type}'" do
        it "returns #{result}" do
          transient_registration.business_type = business_type.to_s
          expect(transient_registration.company_no_required?).to eq(result)
        end
      end
    end
  end

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
