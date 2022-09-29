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

        it "submits" do
          expect(main_people_form.submit(valid_params)).to be true
        end

        it "sets a person_type of 'KEY'" do
          main_people_form.submit(valid_params)
          expect(main_people_form.new_person.person_type).to eq("KEY")
        end
      end

      context "when the form is not valid" do
        let(:invalid_params) { { token: "foo" } }

        it "does not submit" do
          expect(main_people_form.submit(invalid_params)).to be false
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
          before do
            main_people_form.transient_registration.update_attributes(key_people: [build(:key_person, :has_required_data, :main)])
            main_people_form.business_type = "overseas"
          end

          it "submits" do
            expect(main_people_form.submit(blank_params)).to be true
          end
        end

        context "when the transient registration does not have enough main people" do
          before do
            main_people_form.transient_registration.update_attributes(key_people: [build(:key_person, :has_required_data, :main)])
            main_people_form.business_type = "partnership"
          end

          it "does not submit" do
            expect(main_people_form.submit(blank_params)).to be false
          end

          it "raises individual errors for each blank field" do
            main_people_form.submit(blank_params)
            expect(main_people_form.errors.attribute_names).to include(:first_name, :last_name, :dob)
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
        let(:main_people_form) { described_class.new(transient_registration) }

        it "prefills the first_name" do
          first_name = transient_registration.key_people.first.first_name
          expect(main_people_form.first_name).to eq(first_name)
        end

        it "prefills the last_name" do
          last_name = transient_registration.key_people.first.last_name
          expect(main_people_form.last_name).to eq(last_name)
        end

        it "prefills the dob_day" do
          dob_day = transient_registration.key_people.first.dob_day
          expect(main_people_form.dob_day).to eq(dob_day)
        end

        it "prefills the dob_month" do
          dob_month = transient_registration.key_people.first.dob_month
          expect(main_people_form.dob_month).to eq(dob_month)
        end

        it "prefills the dob_year" do
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
          before { main_people_form.first_name = "" }

          it "is not valid" do
            expect(main_people_form).not_to be_valid
          end
        end

        context "when a first_name is too long" do
          before { main_people_form.first_name = "gsm2lgu3q7cg5pcs02ftc1wtpx4lt5ghmyaclhe9qg9li7ibs5ldi3w3n1pt24pbfo0666bq" }

          it "is not valid" do
            expect(main_people_form).not_to be_valid
          end
        end

        context "when a first name contains a special character" do
          it "is not valid" do
            "!@€\#£$%^&*()[]{}?\":;~<>/\\+=".each_char do |c|
              main_people_form.first_name = "ab#{c}123"
              expect(main_people_form).not_to be_valid
            end
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
          before { main_people_form.last_name = "" }

          it "is not valid" do
            expect(main_people_form).not_to be_valid
          end
        end

        context "when a last_name is too long" do
          before { main_people_form.last_name = "gsm2lgu3q7cg5pcs02ftc1wtpx4lt5ghmyaclhe9qg9li7ibs5ldi3w3n1pt24pbfo0666bq" }

          it "is not valid" do
            expect(main_people_form).not_to be_valid
          end
        end

        context "when a last name contains a special character" do
          it "is not valid" do
            "!@€\#£$%^&*()[]{}?\":;~<>/\\+=".each_char do |c|
              main_people_form.last_name = "ab#{c}123"
              expect(main_people_form).not_to be_valid
            end
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
          before do
            main_people_form.dob_day = ""
          end

          it "is not valid" do
            expect(main_people_form).not_to be_valid
          end
        end

        context "when a dob_day is not an integer" do
          before do
            main_people_form.dob_day = "1.5"
          end

          it "is not valid" do
            expect(main_people_form).not_to be_valid
          end
        end

        context "when a dob_day is not in the correct range" do
          before do
            main_people_form.dob_day = "42"
          end

          it "is not valid" do
            expect(main_people_form).not_to be_valid
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
          before do
            main_people_form.dob_month = ""
          end

          it "is not valid" do
            expect(main_people_form).not_to be_valid
          end
        end

        context "when a dob_month is not an integer" do
          before do
            main_people_form.dob_month = "9.75"
          end

          it "is not valid" do
            expect(main_people_form).not_to be_valid
          end
        end

        context "when a dob_month is not in the correct range" do
          before do
            main_people_form.dob_month = "13"
          end

          it "is not valid" do
            expect(main_people_form).not_to be_valid
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
          before do
            main_people_form.dob_year = ""
          end

          it "is not valid" do
            expect(main_people_form).not_to be_valid
          end
        end

        context "when a dob_year is not an integer" do
          before do
            main_people_form.dob_year = "3.14"
          end

          it "is not valid" do
            expect(main_people_form).not_to be_valid
          end
        end

        context "when a dob_year is not in the correct range" do
          before do
            main_people_form.dob_year = (Date.today + 1.year).year.to_i
          end

          it "is not valid" do
            expect(main_people_form).not_to be_valid
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
          before do
            main_people_form.dob_day = ""
            main_people_form.dob_month = ""
            main_people_form.dob_year = ""
          end

          it "is not valid" do
            expect(main_people_form).not_to be_valid
          end
        end

        context "when a dob is not a valid date" do
          before do
            main_people_form.dob = nil
          end

          it "is not valid" do
            expect(main_people_form).not_to be_valid
          end
        end

        context "when the business type is limitedCompany" do
          before do
            main_people_form.business_type = "limitedCompany"
          end

          it "is valid when 16 years old" do
            main_people_form.dob = Date.today - 16.years
            expect(main_people_form).to be_valid
          end

          it "is not valid when less than 16 years old" do
            main_people_form.dob = Date.today - 15.years
            expect(main_people_form).not_to be_valid
          end
        end

        context "when the business type is not limitedCompany" do
          before do
            main_people_form.business_type = "soleTrader"
          end

          it "is valid when 17 years old" do
            main_people_form.dob = Date.today - 17.years
            expect(main_people_form).to be_valid
          end

          it "is not valid when less than 17 years old" do
            main_people_form.dob = Date.today - 16.years
            expect(main_people_form).not_to be_valid
          end
        end
      end
    end
  end
end
