# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe CompanyTradingNameForm, type: :model do
    describe "#submit" do
      context "when the form is valid" do
        let(:company_trading_name_form) { build(:company_trading_name_form, :has_required_data) }
        let(:valid_params) do
          { token: company_trading_name_form.token, company_trading_name: company_trading_name_form.company_trading_name }
        end

        it "should submit" do
          expect(company_trading_name_form.submit(valid_params)).to eq(true)
        end
      end

      context "when the form is not valid" do
        let(:company_trading_name_form) { build(:company_trading_name_form, :has_required_data) }
        let(:invalid_params) { { company_trading_name: "" } }

        it "should not submit" do
          expect(company_trading_name_form.submit(invalid_params)).to eq(false)
        end
      end
    end

    include_examples "validate company_trading_name", :company_trading_name_form
  end
end
