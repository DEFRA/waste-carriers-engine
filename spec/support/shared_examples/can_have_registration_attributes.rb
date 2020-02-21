# frozen_string_literal: true

RSpec.shared_examples "Can have registration attributes" do |factory:|
  let(:resource) { build(factory) }

  include_examples(
    "Can reference single document in collection",
    proc { create(factory, :has_required_data, :has_addresses) },
    :contact_address,
    proc { subject.addresses.find_by(address_type: "POSTAL") },
    WasteCarriersEngine::Address.new,
    :addresses
  )

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

  describe "#overseas?" do
    let(:business_type) { nil }
    let(:resource) { build(factory, location: location, business_type: business_type) }

    context "when the location is outside the UK" do
      let(:location) { "overseas" }

      it "returns true" do
        expect(resource.overseas?).to be_truthy
      end
    end

    context "when the location is not outside the UK" do
      let(:location) { nil }

      context "when the business_type is overseas" do
        let(:business_type) { "overseas" }

        it "returns true" do
          expect(resource.overseas?).to be_truthy
        end
      end

      context "when the business_type is not overseas" do
        let(:business_type) { "soleTrader" }

        it "returns false" do
          expect(resource.overseas?).to be_falsey
        end
      end
    end
  end

  describe "#lower_tier?" do
    let(:resource) { build(factory, tier: tier) }

    context "when a registration's tier is set to 'LOWER'" do
      let(:tier) { "LOWER" }

      it "returns true" do
        expect(resource.lower_tier?).to be_truthy
      end
    end

    context "when a registration's tier is not set to 'LOWER'" do
      let(:tier) { "FOO" }

      it "returns false" do
        expect(resource.lower_tier?).to be_falsey
      end
    end
  end

  describe "#upper_tier?" do
    let(:resource) { build(factory, tier: tier) }

    context "when a registration's tier is set to 'UPPER'" do
      let(:tier) { "UPPER" }

      it "returns true" do
        expect(resource.upper_tier?).to be_truthy
      end
    end

    context "when a registration's tier is not set to 'UPPER'" do
      let(:tier) { "FOO" }

      it "returns false" do
        expect(resource.upper_tier?).to be_falsey
      end
    end
  end

  describe "#amount_paid" do
    it "returns the total amount paid by the user" do
      finance_detail1 = double(:finance_detail1, amount: 23)
      finance_detail2 = double(:finance_detail2, amount: 30)
      finance_details = double(:finance_details, payments: [finance_detail1, finance_detail2])

      expect(resource).to receive(:finance_details).and_return(finance_details)
      expect(resource.amount_paid).to eq(53)
    end

    context "when there are no finance details" do
      it "return 0" do
        expect(resource).to receive(:finance_details)
        expect(resource.amount_paid).to eq(0)
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

  describe "#ad_contact_email?" do
    context "when the contact email is nil" do
      before do
        resource.contact_email = nil
      end

      it "returns true" do
        expect(resource.ad_contact_email?).to eq(true)
      end
    end

    context "when the contact email is the NCCC default" do
      before do
        email = "nccc@example.com"
        allow(WasteCarriersEngine.configuration).to receive(:assisted_digital_email).and_return(email)
        resource.contact_email = email
      end

      it "returns true" do
        expect(resource.ad_contact_email?).to eq(true)
      end
    end

    context "when the contact email is an external email" do
      before do
        resource.contact_email = "foo@example.com"
      end

      it "returns false" do
        expect(resource.ad_contact_email?).to eq(false)
      end
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
