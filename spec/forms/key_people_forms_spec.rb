require "rails_helper"

RSpec.describe KeyPeopleForm, type: :model do
  describe "#submit" do
    context "when the form is valid" do
      let(:key_people_form) { build(:key_people_form, :has_required_data) }
      let(:valid_params) do
        { reg_identifier: key_people_form.reg_identifier,
          first_name: key_people_form.first_name,
          last_name: key_people_form.last_name,
          dob_year: key_people_form.dob_year,
          dob_month: key_people_form.dob_month,
          dob_day: key_people_form.dob_day }
      end

      it "should submit" do
        expect(key_people_form.submit(valid_params)).to eq(true)
      end
    end

    context "when the form is not valid" do
      let(:key_people_form) { build(:key_people_form, :has_required_data) }
      let(:invalid_params) { { reg_identifier: "foo" } }

      it "should not submit" do
        expect(key_people_form.submit(invalid_params)).to eq(false)
      end
    end
  end

  describe "#reg_identifier" do
    context "when a valid transient registration exists" do
      let(:transient_registration) do
        create(:transient_registration,
               :has_required_data,
               workflow_state: "key_people_form")
      end
      # Don't use FactoryBot for this as we need to make sure it initializes with a specific object
      let(:key_people_form) { KeyPeopleForm.new(transient_registration) }

      context "when a reg_identifier meets the requirements" do
        before(:each) do
          key_people_form.reg_identifier = transient_registration.reg_identifier
        end

        it "is valid" do
          expect(key_people_form).to be_valid
        end
      end

      context "when a reg_identifier is blank" do
        before(:each) do
          key_people_form.reg_identifier = ""
        end

        it "is not valid" do
          expect(key_people_form).to_not be_valid
        end
      end
    end
  end

  describe "#transient_registration" do
    context "when the transient registration is invalid" do
      let(:transient_registration) do
        build(:transient_registration,
              workflow_state: "key_people_form")
      end
      # Don't use FactoryBot for this as we need to make sure it initializes with a specific object
      let(:key_people_form) { KeyPeopleForm.new(transient_registration) }

      before(:each) do
        # Make reg_identifier valid for the form, but not the transient object
        key_people_form.reg_identifier = transient_registration.reg_identifier
        transient_registration.reg_identifier = "foo"
      end

      it "is not valid" do
        expect(key_people_form).to_not be_valid
      end

      it "inherits the errors from the transient_registration" do
        key_people_form.valid?
        expect(key_people_form.errors[:base]).to include(I18n.t("mongoid.errors.models.transient_registration.attributes.reg_identifier.invalid_format"))
      end
    end
  end
end
