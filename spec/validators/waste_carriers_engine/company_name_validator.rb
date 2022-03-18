# frozen_string_literal: true

require "rails_helper"

module Test
  CompanyNameValidatable = Struct.new(:company_name) do
    include ActiveModel::Validations

    attr_reader :company_name
    attr_reader :registered_company_name
    attr_reader :business_type
    attr_reader :tier

    validates_with WasteCarriersEngine::CompanyNameValidator, attributes: [:company_name]
  end
end

module WasteCarriersEngine
  # rubocop:disable Metrics/BlockLength
  RSpec.describe CompanyNameValidator do
    subject { Test::CompanyNameValidatable.new }

    RSpec.shared_examples "is valid" do
      it "passes the validity check" do
        expect(subject).to be_valid
      end
    end

    RSpec.shared_examples "is not valid" do
      it "does not pass the validity check" do
        expect(subject).not_to be_valid
      end
    end

    RSpec.shared_examples "business name is required" do
      context "with a business name" do
        before { allow(subject).to receive(:company_name).and_return(Faker::Company.name) }
        it_behaves_like "is valid"
      end
      context "without a business name" do
        before { allow(subject).to receive(:company_name).and_return(nil) }
        it_behaves_like "is not valid"
      end
      context "with a blank business name" do
        before { allow(subject).to receive(:company_name).and_return("") }
        it_behaves_like "is not valid"
      end
    end

    RSpec.shared_examples "business name is optional" do
      context "with a business name" do
        before { allow(subject).to receive(:company_name).and_return(Faker::Company.name) }
        it_behaves_like "is valid"
      end
      context "without a business name" do
        before { allow(subject).to receive(:company_name).and_return(nil) }
        it_behaves_like "is valid"
      end
      context "with a blank business name" do
        before { allow(subject).to receive(:company_name).and_return("") }
        it_behaves_like "is valid"
      end
    end

    RSpec.shared_examples "limited company or limited liability partnership" do
      context "with a registered company name" do
        before { allow(subject).to receive(:registered_company_name).and_return(Faker::Company.name) }
        it_behaves_like "business name is optional"
      end
      context "without a registered company name" do
        before { allow(subject).to receive(:registered_company_name).and_return(nil) }
        it_behaves_like "business name is required"
      end
    end

    describe "#valid?" do
      context "sole trader" do
        before { allow(subject).to receive(:business_type).and_return("soleTrader") }
        context "upper tier" do
          before { allow(subject).to receive(:tier).and_return("UPPER") }
          it_behaves_like "business name is optional"
        end
        context "lower tier" do
          before { allow(subject).to receive(:tier).and_return("LOWER") }
          # WCR does not capture sole trader name for lower tier registrations, so business name is required
          it_behaves_like "business name is required"
        end
      end
      context "limited company" do
        before { allow(subject).to receive(:business_type).and_return("limitedCompany") }
        it_behaves_like "limited company or limited liability partnership"
      end
      context "limited liability partnership" do
        before { allow(subject).to receive(:business_type).and_return("limitedLiabilityPartnership") }
        it_behaves_like "limited company or limited liability partnership"
      end
    end
  end
  # rubocop:enable Metrics/BlockLength
end
