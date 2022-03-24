# frozen_string_literal: true

RSpec.shared_examples "Can present entity display name" do |factory:|

  include_context "Sample registration with defaults", factory
  let(:registration) { resource }

  let(:upper_tier) { WasteCarriersEngine::Registration::UPPER_TIER }
  let(:lower_tier) { WasteCarriersEngine::Registration::LOWER_TIER }

  subject { registration.entity_display_name }

  shared_examples "legal_entity_name trading as trading_as_name" do
    it "returns entity name trading as company_name with truncation" do
      expect(subject).to eq "#{registration.legal_entity_name} trading as #{trading_as_name}"
    end
  end

  shared_examples "legal_entity_name trading as company_name" do
    it "returns entity name trading as company_name" do
      expect(subject).to eq "#{registration.legal_entity_name} trading as #{company_name}"
    end
  end

  shared_examples "simply company_name" do
    it "returns company_name" do
      expect(subject).to eq company_name
    end
  end

  shared_examples "simply legal_entity_name" do
    it "returns the legal entity name" do
      expect(subject).to eq registration.legal_entity_name
    end
  end

  shared_examples "with a company_name with truncation" do
    let(:trading_as_name) { Faker::Company.name }

    context "without 'trading as' detail" do
      let(:company_name) { trading_as_name }
      it_behaves_like "legal_entity_name trading as trading_as_name"
    end

    context "with 'trading as' detail" do
      let(:company_name) { "#{Faker::Company.name} trading as #{trading_as_name}" }
      it_behaves_like "legal_entity_name trading as trading_as_name"
    end

    context "with 't/a' detail" do
      let(:company_name) { "#{Faker::Company.name} t/a #{trading_as_name}" }
      it_behaves_like "legal_entity_name trading as trading_as_name"
    end
  end

  shared_examples "limited company or limited liability partnership" do
    context "with a registered_company_name" do
      let(:registered_company_name) { Faker::Company.name }

      context "when upper tier" do
        let(:tier) { upper_tier }

        it_behaves_like "with a company_name with truncation"

        context "without a registered_company_name and with a company_name" do
          let(:registered_company_name) { nil }

          it_behaves_like "simply company_name"
        end
      end

      context "when lower tier" do
        let(:tier) { lower_tier }
        it_behaves_like "simply company_name"
      end

      context "when lower tier" do
        let(:tier) { lower_tier }
        it_behaves_like "simply company_name"
      end
    end
  end

  describe "#entity_display_name" do
    let(:company_name) { Faker::Lorem.sentence(word_count: 3) }

    context "when the registration business type is 'limitedCompany'" do
      let(:business_type) { "limitedCompany" }
      it_behaves_like "limited company or limited liability partnership"
    end

    context "when the registration business type is 'limitedLiabilityPartnership'" do
      let(:business_type) { "limitedLiabilityPartnership" }
      it_behaves_like "limited company or limited liability partnership"
    end

    context "when the registration business type is 'soleTrader'" do
      let(:business_type) { "soleTrader" }
      # Override the shared example to have a single key person
      let(:key_people) { [person_a] }
      let(:person_name) { "#{key_people[0].first_name} #{key_people[0].last_name}" }

      context "when upper tier" do
        let(:tier) { upper_tier }
        it_behaves_like "with a company_name with truncation"
      end

      context "when lower tier" do
        let(:tier) { lower_tier }
        it_behaves_like "simply company_name"
      end
    end
  end
end
