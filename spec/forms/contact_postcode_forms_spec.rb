require "rails_helper"

RSpec.describe ContactPostcodeForm, type: :model do
  before do
    example_json = { postcode: "BS1 5AH" }
    allow_any_instance_of(AddressFinderService).to receive(:search_by_postcode).and_return(example_json)
  end

  describe "#submit" do
    context "when the form is valid" do
      let(:contact_postcode_form) { build(:contact_postcode_form, :has_required_data) }
      let(:valid_params) { { reg_identifier: contact_postcode_form.reg_identifier, temp_contact_postcode: "BS1 5AH" } }

      it "should submit" do
        expect(contact_postcode_form.submit(valid_params)).to eq(true)
      end

      context "when the postcode is lowercase" do
        before(:each) do
          valid_params[:temp_contact_postcode] = "bs1 6ah"
        end

        it "upcases it" do
          contact_postcode_form.submit(valid_params)
          expect(contact_postcode_form.temp_contact_postcode).to eq("BS1 6AH")
        end
      end

      context "when the postcode has trailing spaces" do
        before(:each) do
          valid_params[:temp_contact_postcode] = "BS1 6AH      "
        end

        it "removes them" do
          contact_postcode_form.submit(valid_params)
          expect(contact_postcode_form.temp_contact_postcode).to eq("BS1 6AH")
        end
      end
    end

    context "when the form is not valid" do
      let(:contact_postcode_form) { build(:contact_postcode_form, :has_required_data) }
      let(:invalid_params) { { reg_identifier: "foo" } }

      it "should not submit" do
        expect(contact_postcode_form.submit(invalid_params)).to eq(false)
      end
    end
  end

  include_examples "validate postcode", form = :contact_postcode_form, field = :temp_contact_postcode

  context "when a form with a valid transient registration exists" do
    let(:contact_postcode_form) { build(:contact_postcode_form, :has_required_data) }

    describe "#reg_identifier" do
      context "when a reg_identifier meets the requirements" do
        it "is valid" do
          expect(contact_postcode_form).to be_valid
        end
      end

      context "when a reg_identifier is blank" do
        before(:each) do
          contact_postcode_form.reg_identifier = ""
        end

        it "is not valid" do
          expect(contact_postcode_form).to_not be_valid
        end
      end
    end
  end

  describe "#transient_registration" do
    context "when the transient registration is invalid" do
      let(:transient_registration) do
        build(:transient_registration,
              workflow_state: "contact_postcode_form")
      end
      # Don't use FactoryBot for this as we need to make sure it initializes with a specific object
      let(:contact_postcode_form) { ContactPostcodeForm.new(transient_registration) }

      before(:each) do
        # Make reg_identifier valid for the form, but not the transient object
        contact_postcode_form.reg_identifier = transient_registration.reg_identifier
        transient_registration.reg_identifier = "foo"
      end

      it "is not valid" do
        expect(contact_postcode_form).to_not be_valid
      end

      it "inherits the errors from the transient_registration" do
        contact_postcode_form.valid?
        expect(contact_postcode_form.errors[:base]).to include(I18n.t("mongoid.errors.models.transient_registration.attributes.reg_identifier.invalid_format"))
      end
    end
  end
end
