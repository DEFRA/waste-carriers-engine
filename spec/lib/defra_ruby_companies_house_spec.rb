# frozen_string_literal: true

require "rails_helper"
require "defra_ruby_companies_house"

RSpec.describe DefraRubyCompaniesHouse do

  let(:valid_company_no) { "00987654" }
  let(:short_company_no) { "1987654" }
  let(:invalid_company_no) { "-" }

  before do
    # stub all calls to fail first...
    stub_request(:get, /#{Rails.configuration.companies_house_host}*/).to_return(
      status: 404
    )
    # ... then add a stub to cover valid company_no values
    stub_request(:get, /#{Rails.configuration.companies_house_host}[A-Z\d]{8}/).to_return(
      status: 200,
      body: File.read("./spec/fixtures/files/companies_house_response.json")
    )
  end

  describe "#company_name" do
    subject(:company_name_for_number) { described_class.new(company_no).company_name }

    context "with an invalid company number" do
      let(:company_no) { invalid_company_no }

      it "raises a standard error" do
        expect { company_name_for_number }.to raise_error(StandardError)
      end
    end

    context "with a valid company number" do
      let(:company_no) { valid_company_no }

      it "returns the company name" do
        expect(company_name_for_number).to eq "BOGUS LIMITED"
      end
    end

    context "with a short company number" do
      let(:company_no) { short_company_no }

      it "returns the company name" do
        expect(company_name_for_number).to eq "BOGUS LIMITED"
      end
    end

    context "with a lower case company number" do
      let(:company_no) { "xy12345z" }

      it "returns the company name" do
        expect(company_name_for_number).to eq "BOGUS LIMITED"
      end
    end

    context "when the request times out" do
      it "raises a standard error" do
        expect { company_name_for_number }.to raise_error(StandardError)
      end
    end

    context "when the request returns an error" do
      before { stub_request(:get, /#{Rails.configuration.companies_house_host}*/).to_raise(SocketError) }

      it "raises an exception" do
        expect { company_name_for_number }.to raise_error(StandardError)
      end
    end
  end

  describe "#registered_office_address_lines" do
    subject(:address_for_company_number) { described_class.new(company_no).registered_office_address_lines }

    context "with an invalid company number" do
      let(:company_no) { invalid_company_no }

      it "raises a standard error" do
        expect { address_for_company_number }.to raise_error(StandardError)
      end
    end

    context "with a valid company number" do
      let(:company_no) { valid_company_no }

      it "returns the address lines" do
        expect(address_for_company_number).to eq ["R House", "Middle Street", "Thereabouts", "HD1 2BN"]
      end
    end

    context "with a short company number" do
      let(:company_no) { short_company_no }

      it "returns the address lines" do
        expect(address_for_company_number).to eq ["R House", "Middle Street", "Thereabouts", "HD1 2BN"]
      end
    end
  end

  describe "#company_status" do
    subject(:company_status) { described_class.new(company_no).company_status }

    context "with an invalid company number" do
      let(:company_no) { invalid_company_no }

      it "raises a standard error" do
        expect { company_status }.to raise_error(StandardError)
      end
    end

    context "when the request times out" do
      it "raises a standard error" do
        expect { company_status }.to raise_error(StandardError)
      end
    end

    context "when the request returns an error" do
      before { stub_request(:get, /#{Rails.configuration.companies_house_host}*/).to_raise(SocketError) }

      it "raises a standard error" do
        expect { company_status }.to raise_error(StandardError)
      end
    end

    context "with a valid company number" do
      let(:company_no) { valid_company_no }

      it "returns the expected status" do
        expect(company_status).to eq "active"
      end
    end
  end
end
