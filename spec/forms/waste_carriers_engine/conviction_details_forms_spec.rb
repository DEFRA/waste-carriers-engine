require "rails_helper"

module WasteCarriersEngine
  RSpec.describe ConvictionDetailsForm, type: :model do
    describe "#submit" do
      let(:conviction_details_form) { build(:conviction_details_form, :has_required_data) }

      context "when the form is valid" do
        let(:valid_params) do
          { reg_identifier: conviction_details_form.reg_identifier,
            first_name: conviction_details_form.first_name,
            last_name: conviction_details_form.last_name,
            position: conviction_details_form.position,
            dob_year: conviction_details_form.dob_year,
            dob_month: conviction_details_form.dob_month,
            dob_day: conviction_details_form.dob_day }
        end

        it "should submit" do
          expect(conviction_details_form.submit(valid_params)).to eq(true)
        end

        it "should set a person_type of 'relevant'" do
          conviction_details_form.submit(valid_params)
          expect(conviction_details_form.new_person.person_type).to eq("relevant")
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
            position: "",
            dob_year: "",
            dob_month: "",
            dob_day: "" }
        end

        context "when the transient registration already has enough people with convictions" do
          before(:each) do
            conviction_details_form.transient_registration.update_attributes(key_people: [build(:key_person, :has_required_data, :relevant)])
          end

          it "should submit" do
            expect(conviction_details_form.submit(blank_params)).to eq(true)
          end
        end

        context "when the transient registration does not have enough people with convictions" do
          before(:each) do
            conviction_details_form.transient_registration.update_attributes(key_people: [build(:key_person, :has_required_data, :main)])
          end

          it "should not submit" do
            expect(conviction_details_form.submit(blank_params)).to eq(false)
          end
        end
      end
    end

    context "when a valid transient registration exists" do
      let(:conviction_details_form) { build(:conviction_details_form, :has_required_data) }

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

      describe "#position" do
        context "when a position meets the requirements" do
          it "is valid" do
            expect(conviction_details_form).to be_valid
          end
        end

        context "when a position is blank" do
          before(:each) do
            conviction_details_form.position = ""
          end

          it "is not valid" do
            expect(conviction_details_form).to_not be_valid
          end
        end

        context "when a position is too long" do
          before(:each) do
            conviction_details_form.position = "gsm2lgu3q7cg5pcs02ftc1wtpx4lt5ghmyaclhe9qg9li7ibs5ldi3w3n1pt24pbfo0666bq"
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

      describe "#dob" do
        context "when a dob meets the requirements" do
          it "is valid" do
            expect(conviction_details_form).to be_valid
          end
        end

        context "when all the dob fields are empty" do
          before(:each) do
            conviction_details_form.dob_day = ""
            conviction_details_form.dob_month = ""
            conviction_details_form.dob_year = ""
          end

          it "is not valid" do
            expect(conviction_details_form).to_not be_valid
          end
        end

        context "when a dob is not a valid date" do
          before(:each) do
            conviction_details_form.dob = nil
          end

          it "is not valid" do
            expect(conviction_details_form).to_not be_valid
          end
        end

        context "when the dob is below the age limit" do
          before(:each) do
            conviction_details_form.dob = Date.today
          end

          it "should not be valid" do
            expect(conviction_details_form).to_not be_valid
          end
        end
      end
    end
  end
end
