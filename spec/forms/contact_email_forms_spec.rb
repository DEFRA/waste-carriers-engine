require "rails_helper"

RSpec.describe ContactEmailForm, type: :model do
  describe "#submit" do
    context "when the form is valid" do
      let(:contact_email_form) { build(:contact_email_form, :has_required_data) }
      let(:valid_params) do
        {
          reg_identifier: contact_email_form.reg_identifier,
          contact_email: contact_email_form.contact_email,
          confirmed_email: contact_email_form.contact_email
        }
      end

      it "should submit" do
        expect(contact_email_form.submit(valid_params)).to eq(true)
      end
    end

    context "when the form is not valid" do
      let(:contact_email_form) { build(:contact_email_form, :has_required_data) }
      let(:invalid_params) { { reg_identifier: "foo" } }

      it "should not submit" do
        expect(contact_email_form.submit(invalid_params)).to eq(false)
      end
    end
  end

  context "when a valid transient registration exists" do
    let(:contact_email_form) { build(:contact_email_form, :has_required_data) }

    describe "#reg_identifier" do
      context "when a reg_identifier meets the requirements" do
        it "is valid" do
          expect(contact_email_form).to be_valid
        end
      end

      context "when a reg_identifier is blank" do
        before(:each) do
          contact_email_form.reg_identifier = ""
        end

        it "is not valid" do
          expect(contact_email_form).to_not be_valid
        end
      end
    end

    describe "#contact_email" do
      context "when a contact_email meets the requirements" do
        it "is valid" do
          expect(contact_email_form).to be_valid
        end
      end

      context "when contact_email and confirmed_email are blank" do
        before(:each) do
          # Update both email fields so we know invalidity isn't triggered by them being different
          contact_email_form.contact_email = ""
          contact_email_form.confirmed_email = contact_email_form.contact_email
        end

        it "is not valid" do
          expect(contact_email_form).to_not be_valid
        end
      end

      context "when a contact_email is in an incorrect format" do
        before(:each) do
          contact_email_form.contact_email = "foo"
          contact_email_form.confirmed_email = contact_email_form.contact_email
        end

        it "is not valid" do
          expect(contact_email_form).to_not be_valid
        end
      end
    end

    describe "#confirmed_email" do
      context "when a confirmed_email meets the requirements" do
        it "is valid" do
          expect(contact_email_form).to be_valid
        end
      end

      context "when a confirmed_email does not match the contact_email" do
        before(:each) { contact_email_form.confirmed_email = "no_matchy@example.com" }

        it "is not valid" do
          expect(contact_email_form).to_not be_valid
        end
      end
    end
  end

  describe "#transient_registration" do
    context "when the transient registration is invalid" do
      let(:transient_registration) do
        build(:transient_registration,
              workflow_state: "contact_email_form")
      end
      # Don't use FactoryBot for this as we need to make sure it initializes with a specific object
      let(:contact_email_form) { ContactEmailForm.new(transient_registration) }

      before(:each) do
        # Make reg_identifier valid for the form, but not the transient object
        contact_email_form.reg_identifier = transient_registration.reg_identifier
        transient_registration.reg_identifier = "foo"
      end

      it "is not valid" do
        expect(contact_email_form).to_not be_valid
      end

      it "inherits the errors from the transient_registration" do
        contact_email_form.valid?
        expect(contact_email_form.errors[:base]).to include(I18n.t("mongoid.errors.models.transient_registration.attributes.reg_identifier.invalid_format"))
      end
    end
  end
end
