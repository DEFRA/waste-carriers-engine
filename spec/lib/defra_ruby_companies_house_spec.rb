# frozen_string_literal: true

require "rails_helper"
require "defra_ruby_companies_house"

RSpec.describe DefraRubyCompaniesHouse do

  let(:valid_company_no) { "00987654" }
  let(:invalid_company_no) { "-" }

  before do
    stub_request(:get, "#{Rails.configuration.companies_house_host}#{valid_company_no}").to_return(
      status: 200,
      body: File.read("./spec/fixtures/files/companies_house_response.json")
    )
    stub_request(:get, "#{Rails.configuration.companies_house_host}#{invalid_company_no}").to_return(
      status: 404
    )
  end

  describe "#company_name" do
    subject { described_class.new(company_no).company_name }

    context "with an invalid company number" do
      let(:company_no) { invalid_company_no }
      it "returns nil" do
        expect(subject).to be_nil
      end
    end

    context "with a valid company number" do
      let(:company_no) { valid_company_no }
      it "returns the company name" do
        expect(subject).to eq "BOGUS LIMITED"
      end
    end
  end

  describe "#registered_office_address_lines" do
    subject { described_class.new(company_no).registered_office_address_lines }

    context "with an invalid company number" do
      let(:company_no) { invalid_company_no }
      it "returns an empty array" do
        expect(subject).to eq []
      end
    end

    context "with a valid company number" do
      let(:company_no) { valid_company_no }
      it "returns the address lines" do
        expect(subject).to eq ["R House", "Middle Street", "Thereabouts", "HD1 2BN"]
      end
    end
  end
end
