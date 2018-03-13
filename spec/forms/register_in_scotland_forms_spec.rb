require "rails_helper"

RSpec.describe RegisterInScotlandForm, type: :model do
  describe "#submit" do
    context "when the form is valid" do
      let(:register_in_scotland_form) { build(:register_in_scotland_form, :has_required_data) }
      let(:valid_params) do
        {
          reg_identifier: register_in_scotland_form.reg_identifier
        }
      end

      it "should submit" do
        expect(register_in_scotland_form.submit(valid_params)).to eq(true)
      end
    end

    context "when the form is not valid" do
      let(:register_in_scotland_form) { build(:register_in_scotland_form, :has_required_data) }
      let(:invalid_params) { { reg_identifier: "foo" } }

      it "should not submit" do
        expect(register_in_scotland_form.submit(invalid_params)).to eq(false)
      end
    end
  end

  context "when a valid transient registration exists" do
    let(:register_in_scotland_form) { build(:register_in_scotland_form, :has_required_data) }

    describe "#reg_identifier" do
      context "when a reg_identifier meets the requirements" do
        it "is valid" do
          expect(register_in_scotland_form).to be_valid
        end
      end

      context "when a reg_identifier is blank" do
        before(:each) do
          register_in_scotland_form.reg_identifier = ""
        end

        it "is not valid" do
          expect(register_in_scotland_form).to_not be_valid
        end
      end
    end
  end

  describe "#transient_registration" do
    context "when the transient registration is invalid" do
      let(:transient_registration) do
        build(:transient_registration,
              workflow_state: "register_in_scotland_form")
      end
      # Don't use FactoryBot for this as we need to make sure it initializes with a specific object
      let(:register_in_scotland_form) { RegisterInScotlandForm.new(transient_registration) }

      before(:each) do
        # Make reg_identifier valid for the form, but not the transient object
        register_in_scotland_form.reg_identifier = transient_registration.reg_identifier
        transient_registration.reg_identifier = "foo"
      end

      it "is not valid" do
        expect(register_in_scotland_form).to_not be_valid
      end

      it "inherits the errors from the transient_registration" do
        register_in_scotland_form.valid?
        expect(register_in_scotland_form.errors[:base]).to include(I18n.t("mongoid.errors.models.transient_registration.attributes.reg_identifier.invalid_format"))
      end
    end
  end
end
