require "rails_helper"

RSpec.describe ConvictionDetailsForm, type: :model do
  describe "#submit" do
    let(:conviction_details_form) { build(:conviction_details_form, :has_required_data) }

    context "when the form is valid" do
      let(:valid_params) do
        { reg_identifier: conviction_details_form.reg_identifier,
          first_name: conviction_details_form.first_name,
          last_name: conviction_details_form.last_name,
          dob_year: conviction_details_form.dob_year,
          dob_month: conviction_details_form.dob_month,
          dob_day: conviction_details_form.dob_day }
      end

      it "should submit" do
        expect(conviction_details_form.submit(valid_params)).to eq(true)
      end
    end

    context "when the form is not valid" do
      let(:invalid_params) { { reg_identifier: "foo" } }

      it "should not submit" do
        expect(conviction_details_form.submit(invalid_params)).to eq(false)
      end
    end

    context "when the form is blank" do
      let(:blank_params) do
        { reg_identifier: conviction_details_form.reg_identifier,
          first_name: "",
          last_name: "",
          dob_year: "",
          dob_month: "",
          dob_day: "" }
      end

      context "when the transient registration already has enough people with convictions" do
        before(:each) do
          conviction_details_form.transient_registration.update_attributes(keyPeople: [build(:key_person, :has_required_data, :relevant)])
        end

        it "should submit" do
          expect(conviction_details_form.submit(blank_params)).to eq(true)
        end
      end

      context "when the transient registration does not have enough people with convictions" do
        before(:each) do
          conviction_details_form.transient_registration.update_attributes(keyPeople: [build(:key_person, :has_required_data, :key)])
        end

        it "should not submit" do
          expect(conviction_details_form.submit(blank_params)).to eq(false)
        end
      end
    end
  end

  context "when a valid transient registration exists" do
    let(:conviction_details_form) { build(:conviction_details_form, :has_required_data) }

    describe "#reg_identifier" do
      context "when a reg_identifier meets the requirements" do
        it "is valid" do
          expect(conviction_details_form).to be_valid
        end
      end

      context "when a reg_identifier is blank" do
        before(:each) do
          conviction_details_form.reg_identifier = ""
        end

        it "is not valid" do
          expect(conviction_details_form).to_not be_valid
        end
      end
    end

    describe "#first_name" do
      context "when a first_name meets the requirements" do
        it "is valid" do
          expect(conviction_details_form).to be_valid
        end
      end

      context "when a first_name is blank" do
        before(:each) do
          conviction_details_form.first_name = ""
        end

        it "is not valid" do
          expect(conviction_details_form).to_not be_valid
        end
      end

      context "when a first_name is too long" do
        before(:each) do
          conviction_details_form.first_name = "gsm2lgu3q7cg5pcs02ftc1wtpx4lt5ghmyaclhe9qg9li7ibs5ldi3w3n1pt24pbfo0666bq"
        end

        it "is not valid" do
          expect(conviction_details_form).to_not be_valid
        end
      end
    end

    describe "#last_name" do
      context "when a last_name meets the requirements" do
        it "is valid" do
          expect(conviction_details_form).to be_valid
        end
      end

      context "when a last_name is blank" do
        before(:each) do
          conviction_details_form.last_name = ""
        end

        it "is not valid" do
          expect(conviction_details_form).to_not be_valid
        end
      end

      context "when a last_name is too long" do
        before(:each) do
          conviction_details_form.last_name = "gsm2lgu3q7cg5pcs02ftc1wtpx4lt5ghmyaclhe9qg9li7ibs5ldi3w3n1pt24pbfo0666bq"
        end

        it "is not valid" do
          expect(conviction_details_form).to_not be_valid
        end
      end
    end

    describe "#dob_day" do
      context "when a dob_day meets the requirements" do
        it "is valid" do
          expect(conviction_details_form).to be_valid
        end
      end

      context "when a dob_day is blank" do
        before(:each) do
          conviction_details_form.dob_day = ""
        end

        it "is not valid" do
          expect(conviction_details_form).to_not be_valid
        end
      end

      context "when a dob_day is not an integer" do
        before(:each) do
          conviction_details_form.dob_day = "1.5"
        end

        it "is not valid" do
          expect(conviction_details_form).to_not be_valid
        end
      end

      context "when a dob_day is not in the correct range" do
        before(:each) do
          conviction_details_form.dob_day = "42"
        end

        it "is not valid" do
          expect(conviction_details_form).to_not be_valid
        end
      end
    end

    describe "#dob_month" do
      context "when a dob_month meets the requirements" do
        it "is valid" do
          expect(conviction_details_form).to be_valid
        end
      end

      context "when a dob_month is blank" do
        before(:each) do
          conviction_details_form.dob_month = ""
        end

        it "is not valid" do
          expect(conviction_details_form).to_not be_valid
        end
      end

      context "when a dob_month is not an integer" do
        before(:each) do
          conviction_details_form.dob_month = "9.75"
        end

        it "is not valid" do
          expect(conviction_details_form).to_not be_valid
        end
      end

      context "when a dob_month is not in the correct range" do
        before(:each) do
          conviction_details_form.dob_month = "13"
        end

        it "is not valid" do
          expect(conviction_details_form).to_not be_valid
        end
      end
    end

    describe "#dob_year" do
      context "when a dob_year meets the requirements" do
        it "is valid" do
          expect(conviction_details_form).to be_valid
        end
      end

      context "when a dob_year is blank" do
        before(:each) do
          conviction_details_form.dob_year = ""
        end

        it "is not valid" do
          expect(conviction_details_form).to_not be_valid
        end
      end

      context "when a dob_year is not an integer" do
        before(:each) do
          conviction_details_form.dob_year = "3.14"
        end

        it "is not valid" do
          expect(conviction_details_form).to_not be_valid
        end
      end

      context "when a dob_year is not in the correct range" do
        before(:each) do
          conviction_details_form.dob_year = (Date.today + 1.year).year.to_i
        end

        it "is not valid" do
          expect(conviction_details_form).to_not be_valid
        end
      end
    end

    describe "#date_of_birth" do
      context "when a date_of_birth meets the requirements" do
        it "is valid" do
          expect(conviction_details_form).to be_valid
        end
      end

      context "when all the date of birth fields are empty" do
        before(:each) do
          conviction_details_form.dob_day = ""
          conviction_details_form.dob_month = ""
          conviction_details_form.dob_year = ""
        end

        it "is not valid" do
          expect(conviction_details_form).to_not be_valid
        end
      end

      context "when a date of birth is not a valid date" do
        before(:each) do
          conviction_details_form.date_of_birth = nil
        end

        it "is not valid" do
          expect(conviction_details_form).to_not be_valid
        end
      end

      context "when the date of birth is below the age limit" do
        before(:each) do
          conviction_details_form.date_of_birth = Date.today
        end

        it "should not be valid" do
          expect(conviction_details_form).to_not be_valid
        end
      end
    end
  end

  describe "#transient_registration" do
    context "when the transient registration is invalid" do
      let(:transient_registration) do
        build(:transient_registration,
              workflow_state: "conviction_details_form")
      end
      # Don't use FactoryBot for this as we need to make sure it initializes with a specific object
      let(:conviction_details_form) { ConvictionDetailsForm.new(transient_registration) }

      before(:each) do
        # Make reg_identifier valid for the form, but not the transient object
        conviction_details_form.reg_identifier = transient_registration.reg_identifier
        transient_registration.reg_identifier = "foo"
      end

      it "is not valid" do
        expect(conviction_details_form).to_not be_valid
      end

      it "inherits the errors from the transient_registration" do
        conviction_details_form.valid?
        expect(conviction_details_form.errors[:base]).to include(I18n.t("mongoid.errors.models.transient_registration.attributes.reg_identifier.invalid_format"))
      end
    end
  end
end
