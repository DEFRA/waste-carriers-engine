require "rails_helper"

RSpec.describe BusinessTypeForm, type: :model do
  describe "#reg_identifier" do
    context "when a valid transient registration exists" do
      let(:transient_registration) do
        create(:transient_registration,
               :has_required_data,
               workflow_state: "business_type_form")
      end
      # Don't use FactoryBot for this as we need to make sure it initializes with a specific object
      let(:business_type_form) { RenewalStartForm.new(transient_registration) }

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

    context "when the transient registration is invalid" do
      let(:transient_registration) do
        build(:transient_registration,
              workflow_state: "business_type_form")
      end
      # Don't use FactoryBot for this as we need to make sure it initializes with a specific object
      let(:business_type_form) { RenewalStartForm.new(transient_registration) }

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
