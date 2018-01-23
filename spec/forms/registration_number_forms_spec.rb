require "rails_helper"

RSpec.describe RegistrationNumberForm, type: :model do
  describe "#submit" do
    context "when the form is valid" do
      let(:registration_number_form) { build(:registration_number_form, :has_required_data) }
      let(:valid_params) { { reg_identifier: registration_number_form.reg_identifier, company_no: "87654321" } }

      it "should submit" do
        expect(registration_number_form.submit(valid_params)).to eq(true)
      end
    end

    context "when the form is not valid" do
      let(:registration_number_form) { build(:registration_number_form, :has_required_data) }
      let(:invalid_params) { { reg_identifier: "foo" } }

      it "should not submit" do
        expect(registration_number_form.submit(invalid_params)).to eq(false)
      end
    end
  end

  context "when a valid transient registration exists" do
    let(:transient_registration) do
      create(:transient_registration,
             :has_required_data,
             workflow_state: "registration_number_form")
    end
    # Don't use FactoryBot for this as we need to make sure it initializes with a specific object
    let(:registration_number_form) { RegistrationNumberForm.new(transient_registration) }

    describe "#reg_identifier" do
      context "when a reg_identifier meets the requirements" do
        before(:each) do
          registration_number_form.reg_identifier = transient_registration.reg_identifier
        end

        it "is valid" do
          expect(registration_number_form).to be_valid
        end
      end

      context "when a reg_identifier is blank" do
        before(:each) do
          registration_number_form.reg_identifier = ""
        end

        it "is not valid" do
          expect(registration_number_form).to_not be_valid
        end
      end
    end

    describe "#company_no" do
      context "when a company_no meets the requirements" do
        before(:each) do
          registration_number_form.reg_identifier = transient_registration.reg_identifier
          registration_number_form.company_no = transient_registration.company_no
        end

        it "is valid" do
          expect(registration_number_form).to be_valid
        end
      end

      context "when a company_no is blank" do
        before(:each) do
          registration_number_form.company_no = ""
        end

        it "is not valid" do
          expect(registration_number_form).to_not be_valid
        end
      end
    end
  end

  describe "#transient_registration" do
    context "when the transient registration is invalid" do
      let(:transient_registration) do
        build(:transient_registration,
              workflow_state: "registration_number_form")
      end
      # Don't use FactoryBot for this as we need to make sure it initializes with a specific object
      let(:registration_number_form) { RegistrationNumberForm.new(transient_registration) }

      before(:each) do
        # Make reg_identifier valid for the form, but not the transient object
        registration_number_form.reg_identifier = transient_registration.reg_identifier
        transient_registration.reg_identifier = "foo"
      end

      it "is not valid" do
        expect(registration_number_form).to_not be_valid
      end

      it "inherits the errors from the transient_registration" do
        registration_number_form.valid?
        expect(registration_number_form.errors[:base]).to include(I18n.t("mongoid.errors.models.transient_registration.attributes.reg_identifier.invalid_format"))
      end
    end
  end
end
