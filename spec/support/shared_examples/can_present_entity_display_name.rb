# frozen_string_literal: true

RSpec.shared_examples "Can present entity display name" do

  include_context("Sample registration with defaults")

  subject { described_class.new(registration, view) }

  shared_examples "trading as" do
    it "returns entity name trading as business name" do
      expect(subject.entity_display_name).to eq "#{entity_name} trading as #{trading_as_name}"
    end
  end

  shared_examples "with and without a business name" do
    context "without a business name" do
      let(:company_name) { nil }

      it "returns the entity name" do
        expect(subject.entity_display_name).to eq entity_name
      end
    end

    context "with a business name" do
      let(:trading_as_name) { Faker::Company.name }

      context "without 'trading as' detail" do
        let(:company_name) { trading_as_name }
        it_behaves_like "trading as"
      end

      context "with 'trading as' detail" do
        let(:company_name) { "#{Faker::Company.name} trading as #{trading_as_name}" }
        it_behaves_like "trading as"
      end

      context "with 't/a' detail" do
        let(:company_name) { "#{Faker::Company.name} t/a #{trading_as_name}" }
        it_behaves_like "trading as"
      end
    end
  end

  shared_examples "limited company or limited liability partnership" do
    let(:entity_name) { registered_name }

    context "with a registered name" do
      let(:registered_name) { Faker::Company.name }

      context "without a business name" do
        let(:company_name) { nil }

        it_behaves_like "with and without a business name"
      end

      context "with a business name" do
        it_behaves_like "with and without a business name"
      end

      context "without a registered name and with a business name" do
        let(:registered_name) { nil }

        it "returns the business name" do
          expect(subject.entity_display_name).to eq company_name
        end
      end
    end
  end

  describe "#entity_display_name" do
    let(:company_name) { Faker::Lorem.sentence(word_count: 3) }

    context "when the registration is lower tier" do
      let(:tier) { "LOWER" }

      it "returns the business name" do
        expect(subject.entity_display_name).to eq company_name
      end
    end

    context "when the registration is upper tier" do

      context "when the registration business type is 'soleTrader'" do
        let(:business_type) { "soleTrader" }
        let(:key_people) { [person_a] }
        let(:entity_name) { "#{key_people[0].first_name} #{key_people[0].last_name}" }

        it_behaves_like "with and without a business name"
      end

      context "when the registration business type is 'limitedCompany'" do
        let(:business_type) { "limitedCompany" }
        it_behaves_like "limited company or limited liability partnership"
      end

      context "when the registration business type is 'limitedLiabilityPartnership'" do
        let(:business_type) { "limitedLiabilityPartnership" }
        it_behaves_like "limited company or limited liability partnership"
      end
    end
  end
end
