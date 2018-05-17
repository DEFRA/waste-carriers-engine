require "rails_helper"

RSpec.describe DeclareConvictionsForm, type: :model do
  describe "#submit" do
    context "when the form is valid" do
      let(:declare_convictions_form) { build(:declare_convictions_form, :has_required_data) }
      let(:valid_params) do
        {
          reg_identifier: declare_convictions_form.reg_identifier,
          declared_convictions: "false"
        }
      end

      it "should submit" do
        expect(declare_convictions_form.submit(valid_params)).to eq(true)
      end
    end

    context "when the form is not valid" do
      let(:declare_convictions_form) { build(:declare_convictions_form, :has_required_data) }
      let(:invalid_params) do
        {
          reg_identifier: declare_convictions_form.reg_identifier,
          declared_convictions: "foo"
        }
      end

      it "should not submit" do
        expect(declare_convictions_form.submit(invalid_params)).to eq(false)
      end
    end
  end

  include_examples "validate boolean", form = :declare_convictions_form, field = :declared_convictions
end
