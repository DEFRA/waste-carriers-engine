require "rails_helper"

RSpec.describe BusinessTypeForm, type: :model do
  describe "#submit" do
    context "when the form is valid" do
      let(:business_type_form) { build(:business_type_form, :has_required_data) }
      let(:valid_params) { { reg_identifier: business_type_form.reg_identifier, business_type: "limitedCompany" } }

      it "should submit" do
        expect(business_type_form.submit(valid_params)).to eq(true)
      end
    end

    context "when the form is not valid" do
      let(:business_type_form) { build(:business_type_form, :has_required_data) }
      let(:invalid_params) { { reg_identifier: "foo", business_type: "foo" } }

      it "should not submit" do
        expect(business_type_form.submit(invalid_params)).to eq(false)
      end
    end
  end

  context "when a valid transient registration exists" do
    let(:business_type_form) { build(:business_type_form, :has_required_data) }

    describe "#business_type" do
      context "when a business_type meets the requirements" do
        it "is valid" do
          expect(business_type_form).to be_valid
        end
      end

      context "when a business_type is blank" do
        before(:each) do
          business_type_form.business_type = ""
        end

        it "is not valid" do
          expect(business_type_form).to_not be_valid
        end
      end

      context "when a business_type is not in the allowed list" do
        before(:each) do
          business_type_form.business_type = "foo"
        end

        it "is not valid" do
          expect(business_type_form).to_not be_valid
        end
      end
    end
  end
end
