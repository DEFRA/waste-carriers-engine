require "rails_helper"

RSpec.describe CompanyPostcodeForm, type: :model do
  describe "#submit" do
    context "when the form is valid" do
      let(:company_postcode_form) { build(:company_postcode_form, :has_required_data) }
      let(:valid_params) { { reg_identifier: company_postcode_form.reg_identifier, company_postcode: "BS1 5AH" } }

      it "should submit" do
        expect(company_postcode_form.submit(valid_params)).to eq(true)
      end
    end

    context "when the form is not valid" do
      let(:company_postcode_form) { build(:company_postcode_form, :has_required_data) }
      let(:invalid_params) { { reg_identifier: "foo" } }

      it "should not submit" do
        expect(company_postcode_form.submit(invalid_params)).to eq(false)
      end
    end
  end

  context "when a form with a valid transient registration exists" do
    let(:company_postcode_form) { build(:company_postcode_form, :has_required_data) }

    describe "#reg_identifier" do
      context "when a reg_identifier meets the requirements" do
        it "is valid" do
          expect(company_postcode_form).to be_valid
        end
      end

      context "when a reg_identifier is blank" do
        before(:each) do
          company_postcode_form.reg_identifier = ""
        end

        it "is not valid" do
          expect(company_postcode_form).to_not be_valid
        end
      end
    end

    describe "#company_postcode" do
      context "when a company_postcode meets the requirements" do
        it "is valid" do
          expect(company_postcode_form).to be_valid
        end
      end

      context "when a company_postcode is blank" do
        before(:each) do
          company_postcode_form.company_postcode = ""
        end

        it "is not valid" do
          expect(company_postcode_form).to_not be_valid
        end
      end

      context "when a company_postcode is too long" do
        before(:each) do
          company_postcode_form.company_postcode = "ABC123DEF567"
        end

        it "is not valid" do
          expect(company_postcode_form).to_not be_valid
        end
      end
    end
  end

  describe "#transient_registration" do
    context "when the transient registration is invalid" do
      let(:transient_registration) do
        build(:transient_registration,
              workflow_state: "company_postcode_form")
      end
      # Don't use FactoryBot for this as we need to make sure it initializes with a specific object
      let(:company_postcode_form) { CompanyPostcodeForm.new(transient_registration) }

      before(:each) do
        # Make reg_identifier valid for the form, but not the transient object
        company_postcode_form.reg_identifier = transient_registration.reg_identifier
        transient_registration.reg_identifier = "foo"
      end

      it "is not valid" do
        expect(company_postcode_form).to_not be_valid
      end

      it "inherits the errors from the transient_registration" do
        company_postcode_form.valid?
        expect(company_postcode_form.errors[:base]).to include(I18n.t("mongoid.errors.models.transient_registration.attributes.reg_identifier.invalid_format"))
      end
    end
  end
end
