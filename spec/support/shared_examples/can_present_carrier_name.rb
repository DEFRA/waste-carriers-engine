# frozen_string_literal: true

RSpec.shared_examples "Can present carrier name" do |factory:|
  let(:resource) { build(factory) }

  context "when the registration is lower tier" do
    let(:lower_tier) { true }
    let(:upper_tier) { false }

    it "returns the company name" do
      expect(subject.carrier_name).to eq(company_name)
    end
  end

  context "when the registration is upper tier" do
    context "when the registration business type is 'soleTrader'" do
      let(:business_type) { "soleTrader" }
      let(:main_people) { [person_a] }

      it "returns the carrier's name" do
        expect(subject.carrier_name).to eq("#{person_a.first_name} #{person_a.last_name}")
      end
    end

    context "when the registration business type is NOT 'sole trader'" do
      it "returns the company name" do
        expect(subject.carrier_name).to eq(company_name)
      end
    end
  end

  let(:registered_name) { Faker::Company.name }
  let(:trading_name) { Faker::Lorem.sentence(word_count: 3) }

  context "with a registered name and without a trading name" do
    before do
      registration.registered_company_name = registered_name
      registration.company_name = nil
    end

    it "returns the registered name" do
      expect(subject.carrier_name).to eq registered_name
    end
  end

  context "without a registered name and with a trading name" do
    before do
      registration.registered_company_name = nil
      registration.company_name = trading_name
    end

    it "returns the trading name" do
      expect(subject.carrier_name).to eq trading_name
    end
  end

  context "with both a registered name and a trading name" do
    before do
      registration.registered_company_name = registered_name
      registration.company_name = trading_name
    end

    it "returns the registered name" do
      expect(subject.carrier_name).to eq "#{registered_name} trading as #{trading_name}"
    end
  end
end
