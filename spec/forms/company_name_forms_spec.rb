require "rails_helper"

RSpec.describe CompanyNameForm, type: :model do
  describe "#submit" do
    context "when the form is valid" do
      let(:company_name_form) { build(:company_name_form, :has_required_data) }
      let(:valid_params) do
        { reg_identifier: company_name_form.reg_identifier, company_name: company_name_form.company_name }
      end

      it "should submit" do
        expect(company_name_form.submit(valid_params)).to eq(true)
      end
    end

    context "when the form is not valid" do
      let(:company_name_form) { build(:company_name_form, :has_required_data) }
      let(:invalid_params) { { reg_identifier: "foo" } }

      it "should not submit" do
        expect(company_name_form.submit(invalid_params)).to eq(false)
      end
    end
  end

  include_examples "validate company_name", form = :company_name_form
end
