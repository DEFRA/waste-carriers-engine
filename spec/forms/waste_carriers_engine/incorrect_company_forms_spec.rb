# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe IncorrectCompanyForm, type: :model do
    describe "#submit" do
      let(:incorrect_company_form) { build(:incorrect_company_form, :has_required_data) }

      context "when the form is valid" do
        let(:valid_params) { { token: incorrect_company_form.token } }

        it "should submit" do
          expect(incorrect_company_form.submit(valid_params)).to be_truthy
        end
      end

      context "when the form is not valid" do
        before do
          expect(incorrect_company_form).to receive(:valid?).and_return(false)
        end

        it "should not submit" do
          expect(incorrect_company_form.submit({})).to be_falsey
        end
      end
    end
  end
end
