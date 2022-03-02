# frozen_string_literal: true

RSpec.shared_examples "Can present entity display name" do

  include_context("Sample registration with defaults")

  subject { described_class.new(registration, view) }

  context "when the registration is lower tier" do
    let(:tier) { "LOWER" }

    it "returns the company name" do
      expect(subject.entity_display_name).to eq(company_name)
    end
  end

  context "when the registration is upper tier" do
    context "when the registration business type is 'soleTrader'" do
      let(:business_type) { "soleTrader" }
      let(:key_people) { [person_a] }

      it "returns the carrier's name" do
        expect(subject.entity_display_name).to eq("#{person_a.first_name} #{person_a.last_name}")
      end
    end

    context "when the registration business type is NOT 'sole trader'" do
      it "returns the company name" do
        expect(subject.entity_display_name).to eq(company_name)
      end
    end
  end

  context "with a registered name and without a trading name" do
    let(:registered_name) { Faker::Company.name }
    let(:company_name) { nil }

    it "returns the registered name" do
      expect(subject.entity_display_name).to eq registered_name
    end
  end

  context "without a registered name and with a trading name" do
    let(:registered_name) { nil }
    let(:company_name) { Faker::Lorem.sentence(word_count: 3) }

    it "returns the trading name" do
      expect(subject.entity_display_name).to eq company_name
    end
  end

  context "with both a registered name and a trading name" do
    let(:registered_name) { Faker::Company.name }
    let(:company_name) { Faker::Lorem.sentence(word_count: 3) }

    it "returns the entity display name" do
      expect(subject.entity_display_name).to eq "#{registered_name} trading as #{company_name}"
    end
  end
end
