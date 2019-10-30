# frozen_string_literal: true

RSpec.shared_examples "Can have registration attributes" do |factory:|
  include_examples(
    "Can reference single document in collection",
    proc { create(factory, :has_required_data, :has_addresses) },
    :contact_address,
    proc { subject.addresses.find_by(address_type: "POSTAL") },
    WasteCarriersEngine::Address.new,
    :addresses
  )

  let(:resource) { build(factory) }

  describe "#charity?" do
    test_values = {
      charity: true,
      limitedCompany: false
    }

    test_values.each do |business_type, result|
      context "when the 'business_type' is '#{business_type}'" do
        it "returns #{result}" do
          resource.business_type = business_type.to_s
          expect(resource.charity?).to eq(result)
        end
      end
    end
  end

  describe "#contact_address" do
    let(:contact_address) { build(:address, :contact) }
    let(:resource) { build(factory, addresses: [contact_address]) }

    it "returns the address of type contact" do
      expect(resource.contact_address).to eq(contact_address)
    end
  end

  describe "#contact_address=" do
    let(:contact_address) { build(:address) }
    let(:resource) { build(factory, addresses: []) }

    it "set an address of type contact" do
      resource.contact_address = contact_address

      expect(resource.addresses).to eq([contact_address])
    end
  end

  describe "#company_no_required?" do
    test_values = {
      limitedCompany: true,
      limitedLiabilityPartnership: true,
      overseas: false
    }

    test_values.each do |business_type, result|
      context "when the 'business_type' is '#{business_type}'" do
        it "returns #{result}" do
          resource.business_type = business_type.to_s
          expect(resource.company_no_required?).to eq(result)
        end
      end
    end
  end

  describe "#conviction_check_required?" do
    context "when there are no conviction_sign_offs" do
      before do
        resource.conviction_sign_offs = nil
      end

      it "returns false" do
        expect(resource.conviction_check_required?).to eq(false)
      end
    end

    context "when there is a conviction_sign_off" do
      before do
        resource.conviction_sign_offs = [build(:conviction_sign_off)]
      end

      context "when confirmed is yes" do
        before do
          resource.conviction_sign_offs.first.confirmed = "yes"
        end

        it "returns false" do
          expect(resource.conviction_check_required?).to eq(false)
        end
      end

      context "when confirmed is no" do
        before do
          resource.conviction_sign_offs.first.confirmed = "no"
        end

        it "returns true" do
          expect(resource.conviction_check_required?).to eq(true)
        end
      end
    end
  end

  describe "#conviction_check_approved?" do
    context "when there are no conviction_sign_offs" do
      before do
        resource.conviction_sign_offs = nil
      end

      it "returns false" do
        expect(resource.conviction_check_approved?).to eq(false)
      end
    end

    context "when there is a conviction_sign_off" do
      before do
        resource.conviction_sign_offs = [build(:conviction_sign_off)]
      end

      context "when confirmed is no" do
        before do
          resource.conviction_sign_offs.first.confirmed = "no"
        end

        it "returns false" do
          expect(resource.conviction_check_approved?).to eq(false)
        end
      end

      context "when confirmed is yes" do
        before do
          resource.conviction_sign_offs.first.confirmed = "yes"
        end

        it "returns true" do
          expect(resource.conviction_check_approved?).to eq(true)
        end
      end
    end
  end

  describe "#unpaid_balance?" do
    context do
      before do
        resource.finance_details = nil
      end

      it "returns false" do
        expect(resource.unpaid_balance?).to eq(false)
      end
    end

    context "when the balance is 0" do
      before do
        resource.finance_details = build(:finance_details, balance: 0)
      end

      it "returns false" do
        expect(resource.unpaid_balance?).to eq(false)
      end
    end

    context "when the balance is negative" do
      before do
        resource.finance_details = build(:finance_details, balance: -1)
      end

      it "returns false" do
        expect(resource.unpaid_balance?).to eq(false)
      end
    end

    context "when the balance is positive" do
      before do
        resource.finance_details = build(:finance_details, balance: 1)
      end

      it "returns true" do
        expect(resource.unpaid_balance?).to eq(true)
      end
    end
  end
end
