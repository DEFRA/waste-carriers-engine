require "rails_helper"

RSpec.describe ContactPhoneForm, type: :model do
  describe "#submit" do
    context "when the form is valid" do
      let(:contact_phone_form) { build(:contact_phone_form, :has_required_data) }
      let(:valid_params) do
        {
          reg_identifier: contact_phone_form.reg_identifier,
          phone_number: contact_phone_form.phone_number
        }
      end

      it "should submit" do
        expect(contact_phone_form.submit(valid_params)).to eq(true)
      end
    end

    context "when the form is not valid" do
      let(:contact_phone_form) { build(:contact_phone_form, :has_required_data) }
      let(:invalid_params) do
        {
          reg_identifier: "foo",
          phone_number: "foo"
        }
      end

      it "should not submit" do
        expect(contact_phone_form.submit(invalid_params)).to eq(false)
      end
    end
  end

  include_examples "validate phone_number", form = :contact_phone_form

  context "when a valid transient registration exists" do
    let(:contact_phone_form) { build(:contact_phone_form, :has_required_data) }

    describe "#reg_identifier" do
      context "when a reg_identifier meets the requirements" do
        it "is valid" do
          expect(contact_phone_form).to be_valid
        end
      end

      context "when a reg_identifier is blank" do
        before(:each) do
          contact_phone_form.reg_identifier = ""
        end

        it "is not valid" do
          expect(contact_phone_form).to_not be_valid
        end
      end
    end
  end

  describe "#transient_registration" do
    context "when the transient registration is invalid" do
      let(:transient_registration) do
        build(:transient_registration,
              workflow_state: "contact_phone_form")
      end
      # Don't use FactoryBot for this as we need to make sure it initializes with a specific object
      let(:contact_phone_form) { ContactPhoneForm.new(transient_registration) }

      before(:each) do
        # Make reg_identifier valid for the form, but not the transient object
        contact_phone_form.reg_identifier = transient_registration.reg_identifier
        transient_registration.reg_identifier = "foo"
      end

      it "is not valid" do
        expect(contact_phone_form).to_not be_valid
      end

      it "inherits the errors from the transient_registration" do
        contact_phone_form.valid?
        expect(contact_phone_form.errors[:base]).to include(I18n.t("mongoid.errors.models.transient_registration.attributes.reg_identifier.invalid_format"))
      end
    end
  end
end
