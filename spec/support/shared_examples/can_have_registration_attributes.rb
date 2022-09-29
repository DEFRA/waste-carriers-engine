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

  describe "#declared_convictions?" do
    context "when the resource has declared convictions" do
      let(:resource) { build(factory, declared_convictions: "yes") }

      it "returns true" do
        expect(resource.declared_convictions?).to be true
      end
    end

    context "when the resource has no declared convictions" do
      let(:resource) { build(factory, declared_convictions: "no") }

      it "returns false" do
        expect(resource.declared_convictions?).to be false
      end
    end
  end

  describe "#uk_location?" do
    let(:resource) { build(factory, location: location) }

    %w[england scotland wales northern_ireland].each do |uk_location|
      context "when the location is #{uk_location}" do
        let(:location) { uk_location }

        it "returns true" do
          expect(resource).to be_uk_location
        end
      end
    end

    context "when the location is overseas" do
      let(:location) { "overseas" }

      it "returns false" do
        expect(resource).not_to be_uk_location
      end
    end

    context "when the location is nil" do
      let(:location) { nil }

      it "returns false" do
        expect(resource).not_to be_uk_location
      end
    end
  end

  describe "#overseas?" do
    let(:location) { nil }
    let(:business_type) { nil }
    let(:resource) { build(factory, location: location, business_type: business_type) }

    context "when the location is within the UK" do
      before { allow(resource).to receive(:uk_location?).and_return(true) }

      it "returns false" do
        expect(resource).not_to be_overseas
      end
    end

    context "when the location is outside the UK" do
      let(:location) { "overseas" }

      it "returns true" do
        expect(resource).to be_overseas
      end
    end

    context "when the location is nil" do
      context "when the business_type is overseas" do
        let(:business_type) { "overseas" }

        it "returns true" do
          expect(resource).to be_overseas
        end
      end

      context "when the business_type is not overseas" do
        let(:business_type) { "soleTrader" }

        it "returns false" do
          expect(resource).not_to be_overseas
        end
      end
    end
  end

  describe "#lower_tier?" do
    let(:resource) { build(factory, tier: tier) }

    context "when a registration's tier is set to 'LOWER'" do
      let(:tier) { "LOWER" }

      it "returns true" do
        expect(resource).to be_lower_tier
      end
    end

    context "when a registration's tier is not set to 'LOWER'" do
      let(:tier) { "FOO" }

      it "returns false" do
        expect(resource).not_to be_lower_tier
      end
    end
  end

  describe "#upper_tier?" do
    let(:resource) { build(factory, tier: tier) }

    context "when a registration's tier is set to 'UPPER'" do
      let(:tier) { "UPPER" }

      it "returns true" do
        expect(resource).to be_upper_tier
      end
    end

    context "when a registration's tier is not set to 'UPPER'" do
      let(:tier) { "FOO" }

      it "returns false" do
        expect(resource).not_to be_upper_tier
      end
    end
  end

  describe "#amount_paid" do
    it "returns the total amount paid by the user" do
      finance_detail1 = double(:finance_detail1, amount: 23)
      finance_detail2 = double(:finance_detail2, amount: 30)
      finance_details = double(:finance_details, payments: [finance_detail1, finance_detail2])

      allow(resource).to receive(:finance_details).and_return(finance_details)

      expect(resource.amount_paid).to eq(53)
    end

    context "when there are no finance details" do
      it "returns 0" do
        allow(resource).to receive(:finance_details)

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

  describe "#assisted_digital?" do
    context "when the contact email is nil" do
      before do
        resource.contact_email = nil
      end

      it "returns true" do
        expect(resource).to be_assisted_digital
      end
    end

    context "when the contact email is the nil" do
      before do
        resource.contact_email = nil
      end

      it "returns true" do
        expect(resource).to be_assisted_digital
      end
    end

    context "when the contact email is an external email" do
      before do
        resource.contact_email = "foo@example.com"
      end

      it "returns false" do
        expect(resource).not_to be_assisted_digital
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
        expect(resource).not_to be_conviction_check_required
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
          expect(resource).not_to be_conviction_check_required
        end
      end

      context "when confirmed is no" do
        before do
          resource.conviction_sign_offs.first.confirmed = "no"
        end

        it "returns true" do
          expect(resource).to be_conviction_check_required
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
        expect(resource).not_to be_conviction_check_approved
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
          expect(resource).not_to be_conviction_check_approved
        end
      end

      context "when confirmed is yes" do
        before do
          resource.conviction_sign_offs.first.confirmed = "yes"
        end

        it "returns true" do
          expect(resource).to be_conviction_check_approved
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
        expect(resource).not_to be_unpaid_balance
      end
    end

    context "when the balance is 0" do
      before do
        resource.finance_details = build(:finance_details, balance: 0)
      end

      it "returns false" do
        expect(resource).not_to be_unpaid_balance
      end
    end

    context "when the balance is negative" do
      before do
        resource.finance_details = build(:finance_details, balance: -1)
      end

      it "returns false" do
        expect(resource).not_to be_unpaid_balance
      end
    end

    context "when the balance is positive" do
      before do
        resource.finance_details = build(:finance_details, balance: 1)
      end

      it "returns true" do
        expect(resource).to be_unpaid_balance
      end
    end
  end

  describe "#email_to_send_receipt" do
    let(:receipt_email) { "receipt@example.com" }
    let(:contact_email) { "contact@example.com" }

    context "when the receipt email is set" do
      before do
        resource.receipt_email = receipt_email
      end

      it "returns the receipt email" do
        expect(resource.email_to_send_receipt).to eq(receipt_email)
      end
    end

    context "when the receipt email is nil" do
      before do
        resource.receipt_email = nil
      end

      context "when the contact email is set" do
        before do
          resource.contact_email = contact_email
        end

        it "returns the contact email" do
          expect(resource.email_to_send_receipt).to eq(contact_email)
        end
      end

      context "when the contact email is nil" do
        before do
          resource.contact_email = nil
        end

        it "returns nil" do
          expect(resource.email_to_send_receipt).to eq(nil)
        end
      end
    end
  end

  describe "#legal_entity_name" do
    let(:person_a) { build(:key_person, :main, first_name: Faker::Name.first_name, last_name: Faker::Name.last_name) }
    let(:key_people) { [person_a] }
    let(:registered_company_name) { nil }
    let(:tier) { WasteCarriersEngine::Registration::UPPER_TIER }
    let(:company_name) { nil }
    let(:resource) do
      build(factory,
            business_type: business_type,
            tier: tier,
            registered_company_name: registered_company_name,
            key_people: key_people)
    end

    subject { resource.legal_entity_name }

    shared_examples "returns registered_company_name" do
      it "returns the registered company name" do
        expect(subject).to eq registered_company_name
      end
    end

    shared_examples "returns nil" do
      it "returns nil" do
        expect(subject).to be_nil
      end
    end

    shared_examples "LTD or LLP" do
      context "with a registered company name" do
        let(:registered_company_name) { Faker::Company.name }

        context "without a business name" do
          it_behaves_like "returns registered_company_name"
        end

        context "with a business name" do
          let(:company_name) { Faker::Company.name }
          it_behaves_like "returns registered_company_name"
        end
      end

      context "without a registered company name" do
        let(:registered_company_name) { nil }

        context "without a business name" do
          it_behaves_like "returns nil"
        end

        context "with a business name" do
          let(:company_name) { Faker::Company.name }
          it_behaves_like "returns nil"
        end
      end
    end

    context "with a sole trader" do
      let(:business_type) { "soleTrader" }

      context "with an upper tier registration" do
        it "returns the sole trader's name" do
          expect(subject).to eq "#{resource.key_people[0].first_name} #{resource.key_people[0].last_name}"
        end
      end

      context "with a lower tier registration" do
        let(:tier) { WasteCarriersEngine::Registration::LOWER_TIER }
        it "returns nil" do
          expect(subject).to be_nil
        end
      end
    end

    context "with a limited company" do
      let(:business_type) { "limitedCompany" }
      it_behaves_like "LTD or LLP"
    end

    context "with a limited liability partnership" do
      let(:business_type) { "limitedLiabilityPartnership" }
      it_behaves_like "LTD or LLP"
    end
  end

  describe "#company_name_required?" do
    let(:registered_company_name) { nil }
    let(:resource) do
      build(factory, business_type: business_type, tier: tier, registered_company_name: registered_company_name)
    end

    subject { resource.company_name_required? }

    shared_examples "it is required for lower tier only" do
      context "with an upper tier registration" do
        let(:tier) { WasteCarriersEngine::Registration::UPPER_TIER }
        it "returns false" do
          expect(subject).to be false
        end
      end

      context "with a lower tier registration" do
        let(:tier) { WasteCarriersEngine::Registration::LOWER_TIER }
        it "returns true" do
          expect(subject).to be true
        end
      end
    end

    context "with a limited company" do
      let(:business_type) { "limitedCompany" }
      it_behaves_like "it is required for lower tier only"
    end

    context "with a limited liability partnership" do
      let(:business_type) { "limitedLiabilityPartnership" }
      it_behaves_like "it is required for lower tier only"
    end

    context "with a sole trader" do
      let(:business_type) { "soleTrader" }
      it_behaves_like "it is required for lower tier only"
    end

    context "with an overseas business" do
      let(:business_type) { "soleTrader" }
      let(:tier) { WasteCarriersEngine::Registration::UPPER_TIER }
      before { resource.location = "overseas" }

      it "returns true" do
        expect(subject).to be true
      end
    end
  end
end
