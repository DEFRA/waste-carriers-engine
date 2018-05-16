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

  context "when a valid transient registration exists" do
    let(:declare_convictions_form) { build(:declare_convictions_form, :has_required_data) }

    describe "#declared_convictions" do
      context "when a declared_convictions is true" do
        before(:each) do
          declare_convictions_form.declared_convictions = true
        end

        it "is valid" do
          expect(declare_convictions_form).to be_valid
        end
      end

      context "when a declared_convictions is false" do
        before(:each) do
          declare_convictions_form.declared_convictions = false
        end

        it "is valid" do
          expect(declare_convictions_form).to be_valid
        end
      end

      context "when a declared_convictions is not a boolean" do
        before(:each) do
          declare_convictions_form.declared_convictions = "foo"
        end

        it "is not valid" do
          expect(declare_convictions_form).to_not be_valid
        end
      end

      context "when a declared_convictions is blank" do
        before(:each) do
          declare_convictions_form.declared_convictions = ""
        end

        it "is not valid" do
          expect(declare_convictions_form).to_not be_valid
        end
      end
    end
  end
end
