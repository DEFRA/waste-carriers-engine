require "rails_helper"

RSpec.describe BusinessTypeForm, type: :model do
  describe "#submit" do
    context "when the form is valid" do
      let(:business_type_form) { build(:business_type_form, :has_required_data) }
      let(:valid_params) { { reg_identifier: business_type_form.reg_identifier } }

      it "should submit" do
        expect(business_type_form.submit(valid_params)).to eq(true)
      end
    end

    context "when the form is not valid" do
      let(:business_type_form) { build(:business_type_form, :has_required_data) }
      let(:invalid_params) { { reg_identifier: "foo" } }

      it "should not submit" do
        expect(business_type_form.submit(invalid_params)).to eq(false)
      end
    end
  end

  describe "#reg_identifier" do
    context "when a valid transient registration exists" do
      let(:transient_registration) do
        create(:transient_registration,
               :has_required_data,
               workflow_state: "business_type_form")
      end
      # Don't use FactoryBot for this as we need to make sure it initializes with a specific object
      let(:business_type_form) { BusinessTypeForm.new(transient_registration) }

      context "when a reg_identifier meets the requirements" do
        before(:each) do
          business_type_form.reg_identifier = transient_registration.reg_identifier
        end

        it "is valid" do
          expect(business_type_form).to be_valid
        end
      end

      context "when a reg_identifier is blank" do
        before(:each) do
          business_type_form.reg_identifier = ""
        end

        it "is not valid" do
          expect(business_type_form).to_not be_valid
        end
      end
    end
  end

  describe "#transient_registration" do
    context "when the transient registration is invalid" do
      let(:transient_registration) do
        build(:transient_registration,
              workflow_state: "business_type_form")
      end
      # Don't use FactoryBot for this as we need to make sure it initializes with a specific object
      let(:business_type_form) { BusinessTypeForm.new(transient_registration) }

      it "is not valid" do
        business_type_form.reg_identifier = transient_registration.reg_identifier
        expect(business_type_form).to_not be_valid
      end

      it "inherits the errors from the transient_registration" do
        business_type_form.reg_identifier = transient_registration.reg_identifier
        business_type_form.valid?
        expect(business_type_form.errors[:base]).to include(I18n.t("mongoid.errors.models.transient_registration.attributes.reg_identifier.invalid_format"))
      end
    end
  end
end
