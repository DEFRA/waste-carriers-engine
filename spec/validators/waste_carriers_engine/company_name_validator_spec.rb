# frozen_string_literal: true

require "rails_helper"

module Test
  CompanyNameValidatable = Struct.new(:company_name) do
    include ActiveModel::Validations

    attr_reader :company_name
    attr_reader :registered_company_name
    attr_reader :business_type
    attr_reader :tier

    def company_name_required? = true

    def temp_use_trading_name = "no"

    validates_with WasteCarriersEngine::CompanyNameValidator, attributes: [:company_name]
  end
end

module WasteCarriersEngine
  RSpec.describe CompanyNameValidator do
    subject(:validatable) { Test::CompanyNameValidatable.new }

    RSpec.shared_examples "is valid" do
      it "passes the validity check" do
        expect(validatable).to be_valid
      end
    end

    RSpec.shared_examples "is not valid" do
      it "does not pass the validity check" do
        expect(validatable).not_to be_valid
      end
    end

    RSpec.shared_examples "business name is required" do
      before { allow(validatable).to receive(:company_name_required?).and_return(true) }

      context "with a business name" do
        before { allow(validatable).to receive(:company_name).and_return(Faker::Company.name) }

        it_behaves_like "is valid"
      end

      context "without a business name" do
        before { allow(validatable).to receive(:company_name).and_return(nil) }

        it_behaves_like "is not valid"
      end

      context "with a blank business name" do
        before { allow(validatable).to receive(:company_name).and_return("") }

        it_behaves_like "is not valid"
      end
    end

    RSpec.shared_examples "business name is optional" do
      before { allow(validatable).to receive(:company_name_required?).and_return(false) }

      context "with a business name" do
        before { allow(validatable).to receive(:company_name).and_return(Faker::Company.name) }

        it_behaves_like "is valid"
      end

      context "without a business name" do
        before { allow(validatable).to receive(:company_name).and_return(nil) }

        it_behaves_like "is valid"
      end

      context "with a blank business name" do
        before { allow(validatable).to receive(:company_name).and_return("") }

        it_behaves_like "is valid"
      end
    end

    RSpec.shared_examples "limited company or limited liability partnership" do
      context "with a registered company name" do
        before { allow(validatable).to receive(:registered_company_name).and_return(Faker::Company.name) }

        it_behaves_like "business name is optional"
      end

      context "without a registered company name" do
        before { allow(validatable).to receive(:registered_company_name).and_return(nil) }

        it_behaves_like "business name is required"
      end
    end

    describe "#valid?" do
      context "with a sole trader" do
        before { allow(validatable).to receive(:business_type).and_return("soleTrader") }

        context "with an upper tier registration" do
          before { allow(validatable).to receive(:tier).and_return("UPPER") }

          it_behaves_like "business name is optional"
        end

        context "with a lower tier registration" do
          before { allow(validatable).to receive(:tier).and_return("LOWER") }

          # WCR does not capture sole trader name for lower tier registrations, so business name is required
          it_behaves_like "business name is required"
        end
      end

      context "with a limited company" do
        before { allow(validatable).to receive(:business_type).and_return("limitedCompany") }

        it_behaves_like "limited company or limited liability partnership"
      end

      context "with a limited liability partnership" do
        before { allow(validatable).to receive(:business_type).and_return("limitedLiabilityPartnership") }

        it_behaves_like "limited company or limited liability partnership"
      end
    end
  end
end
