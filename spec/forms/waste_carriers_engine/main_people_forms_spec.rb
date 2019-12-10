# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe MainPeopleForm, type: :model do
    describe "#submit" do
      let(:main_people_form) { build(:main_people_form, :has_required_data) }

      context "when the form is valid" do
        let(:valid_params) do
          { token: main_people_form.token,
            first_name: main_people_form.first_name,
            last_name: main_people_form.last_name,
            dob_year: main_people_form.dob_year,
            dob_month: main_people_form.dob_month,
            dob_day: main_people_form.dob_day }
        end

        it "should submit" do
          expect(main_people_form.submit(valid_params)).to eq(true)
        end

        it "should set a person_type of 'KEY'" do
          main_people_form.submit(valid_params)
          expect(main_people_form.new_person.person_type).to eq("KEY")
        end
      end

      context "when the form is not valid" do
        let(:invalid_params) { { token: "foo" } }

        it "should not submit" do
          expect(main_people_form.submit(invalid_params)).to eq(false)
        end
      end

      context "when the form is blank" do
        let(:blank_params) do
          { token: main_people_form.token,
            first_name: "",
            last_name: "",
            dob_year: "",
            dob_month: "",
            dob_day: "" }
        end

        context "when the transient registration already has enough main people" do
          before(:each) do
            main_people_form.transient_registration.update_attributes(key_people: [build(:key_person, :has_required_data, :main)])
            main_people_form.business_type = "overseas"
          end

          it "should submit" do
            expect(main_people_form.submit(blank_params)).to eq(true)
          end
        end

        context "when the transient registration does not have enough main people" do
          before(:each) do
            main_people_form.transient_registration.update_attributes(key_people: [build(:key_person, :has_required_data, :main)])
            main_people_form.business_type = "partnership"
          end

          it "should not submit" do
            expect(main_people_form.submit(blank_params)).to eq(false)
          end
        end
      end
    end

    describe "#initialize" do
      context "when a main person already exists and it's a sole trader" do
        let(:transient_registration) do
          create(:renewing_registration,
                 :has_required_data,
                 business_type: "soleTrader",
                 key_people: [build(:key_person, :has_required_data, :main)])
        end
        let(:main_people_form) { MainPeopleForm.new(transient_registration) }

        it "should prefill the first_name" do
          first_name = transient_registration.key_people.first.first_name
          expect(main_people_form.first_name).to eq(first_name)
        end

        it "should prefill the last_name" do
          last_name = transient_registration.key_people.first.last_name
          expect(main_people_form.last_name).to eq(last_name)
        end

        it "should prefill the dob_day" do
          dob_day = transient_registration.key_people.first.dob_day
          expect(main_people_form.dob_day).to eq(dob_day)
        end

        it "should prefill the dob_month" do
          dob_month = transient_registration.key_people.first.dob_month
          expect(main_people_form.dob_month).to eq(dob_month)
        end

        it "should prefill the dob_year" do
          dob_year = transient_registration.key_people.first.dob_year
          expect(main_people_form.dob_year).to eq(dob_year)
        end
      end
    end

    context "when a valid transient registration exists" do
      let(:main_people_form) { build(:main_people_form, :has_required_data) }

      describe "#first_name" do
        context "when a first_name meets the requirements" do
          it "is valid" do
            expect(main_people_form).to be_valid
          end
        end

        context "when a first_name is blank" do
          before(:each) do
            main_people_form.first_name = ""
          end

          it "is not valid" do
            expect(main_people_form).to_not be_valid
          end
        end

        context "when a first_name is too long" do
          before(:each) do
            main_people_form.first_name = "gsm2lgu3q7cg5pcs02ftc1wtpx4lt5ghmyaclhe9qg9li7ibs5ldi3w3n1pt24pbfo0666bq"
          end

          it "is not valid" do
            expect(main_people_form).to_not be_valid
          end
        end
      end

      describe "#last_name" do
        context "when a last_name meets the requirements" do
          it "is valid" do
            expect(main_people_form).to be_valid
          end
        end

        context "when a last_name is blank" do
          before(:each) do
            main_people_form.last_name = ""
          end

          it "is not valid" do
            expect(main_people_form).to_not be_valid
          end
        end

        context "when a last_name is too long" do
          before(:each) do
            main_people_form.last_name = "gsm2lgu3q7cg5pcs02ftc1wtpx4lt5ghmyaclhe9qg9li7ibs5ldi3w3n1pt24pbfo0666bq"
          end

          it "is not valid" do
            expect(main_people_form).to_not be_valid
          end
        end
      end

      describe "#dob_day" do
        context "when a dob_day meets the requirements" do
          it "is valid" do
            expect(main_people_form).to be_valid
          end
        end

        context "when a dob_day is blank" do
          before(:each) do
            main_people_form.dob_day = ""
          end

          it "is not valid" do
            expect(main_people_form).to_not be_valid
          end
        end

        context "when a dob_day is not an integer" do
          before(:each) do
            main_people_form.dob_day = "1.5"
          end

          it "is not valid" do
            expect(main_people_form).to_not be_valid
          end
        end

        context "when a dob_day is not in the correct range" do
          before(:each) do
            main_people_form.dob_day = "42"
          end

          it "is not valid" do
            expect(main_people_form).to_not be_valid
          end
        end
      end

      describe "#dob_month" do
        context "when a dob_month meets the requirements" do
          it "is valid" do
            expect(main_people_form).to be_valid
          end
        end

        context "when a dob_month is blank" do
          before(:each) do
            main_people_form.dob_month = ""
          end

          it "is not valid" do
            expect(main_people_form).to_not be_valid
          end
        end

        context "when a dob_month is not an integer" do
          before(:each) do
            main_people_form.dob_month = "9.75"
          end

          it "is not valid" do
            expect(main_people_form).to_not be_valid
          end
        end

        context "when a dob_month is not in the correct range" do
          before(:each) do
            main_people_form.dob_month = "13"
          end

          it "is not valid" do
            expect(main_people_form).to_not be_valid
          end
        end
      end

      describe "#dob_year" do
        context "when a dob_year meets the requirements" do
          it "is valid" do
            expect(main_people_form).to be_valid
          end
        end

        context "when a dob_year is blank" do
          before(:each) do
            main_people_form.dob_year = ""
          end

          it "is not valid" do
            expect(main_people_form).to_not be_valid
          end
        end

        context "when a dob_year is not an integer" do
          before(:each) do
            main_people_form.dob_year = "3.14"
          end

          it "is not valid" do
            expect(main_people_form).to_not be_valid
          end
        end

        context "when a dob_year is not in the correct range" do
          before(:each) do
            main_people_form.dob_year = (Date.today + 1.year).year.to_i
          end

          it "is not valid" do
            expect(main_people_form).to_not be_valid
          end
        end
      end

      describe "#dob" do
        context "when a dob meets the requirements" do
          it "is valid" do
            expect(main_people_form).to be_valid
          end
        end

        context "when all the dob fields are empty" do
          before(:each) do
            main_people_form.dob_day = ""
            main_people_form.dob_month = ""
            main_people_form.dob_year = ""
          end

          it "is not valid" do
            expect(main_people_form).to_not be_valid
          end
        end

        context "when a dob is not a valid date" do
          before(:each) do
            main_people_form.dob = nil
          end

          it "is not valid" do
            expect(main_people_form).to_not be_valid
          end
        end

        shared_examples_for "age limits for main people" do |business_type, age_limit|
          before(:each) do
            main_people_form.business_type = business_type
          end

          it "should be valid when at the age limit" do
            main_people_form.dob = Date.today - age_limit.years
            expect(main_people_form).to be_valid
          end

          it "should not be valid when under the age limit" do
            main_people_form.dob = Date.today - (age_limit.years - 1.year)
            expect(main_people_form).to_not be_valid
          end
        end

        {
          # Permutation table of business_type and age limit
          "localAuthority" => 17,
          "limitedCompany" => 16,
          "limitedLiabilityPartnership" => 17,
          "overseas" => 17,
          "partnership" => 17,
          "soleTrader" => 17
        }.each do |business_type, age_limit|
          it_behaves_like "age limits for main people", business_type, age_limit
        end
      end
    end
  end
end
