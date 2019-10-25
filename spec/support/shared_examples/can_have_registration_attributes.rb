# frozen_string_literal: true

RSpec.shared_examples "Can have registration attributes" do
  include_examples(
    "Can reference single document in collection",
    proc { create(:transient_registration, :has_required_data, :has_addresses) },
    :contact_address,
    proc { subject.addresses.find_by(address_type: "POSTAL") },
    WasteCarriersEngine::Address.new,
    :addresses
  )

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

  describe "#contact_address" do
    let(:contact_address) { build(:address, :contact) }
    let(:transient_registration) { build(:transient_registration, addresses: [contact_address]) }

    it "returns the address of type contact" do
      expect(transient_registration.contact_address).to eq(contact_address)
    end
  end

  describe "#contact_address=" do
    let(:contact_address) { build(:address) }
    let(:transient_registration) { build(:transient_registration, addresses: []) }

    it "set an address of type contact" do
      transient_registration.contact_address = contact_address

      expect(transient_registration.addresses).to eq([contact_address])
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

  describe "#unpaid_balance?" do
    context do
      before do
        transient_registration.finance_details = nil
      end

      it "returns false" do
        expect(transient_registration.unpaid_balance?).to eq(false)
      end
    end

    context "when the balance is 0" do
      before do
        transient_registration.finance_details = build(:finance_details, balance: 0)
      end

      it "returns false" do
        expect(transient_registration.unpaid_balance?).to eq(false)
      end
    end

    context "when the balance is negative" do
      before do
        transient_registration.finance_details = build(:finance_details, balance: -1)
      end

      it "returns false" do
        expect(transient_registration.unpaid_balance?).to eq(false)
      end
    end

    context "when the balance is positive" do
      before do
        transient_registration.finance_details = build(:finance_details, balance: 1)
      end

      it "returns true" do
        expect(transient_registration.unpaid_balance?).to eq(true)
      end
    end
  end
end
