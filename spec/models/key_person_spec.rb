require "rails_helper"

RSpec.describe KeyPerson, type: :model do
  describe "#date_of_birth" do
    context "when the provided fields make a valid date" do
      # Can't use factories as we have to trigger the after_initialize method at correct time
      let(:key_person) { KeyPerson.new(dob_day: 1, dob_month: 2, dob_year: 2000) }

      it "should return the date when setting date of birth" do
        expect(key_person.date_of_birth).to eq(Date.new(key_person.dob_year,
                                                        key_person.dob_month,
                                                        key_person.dob_day))
      end
    end

    context "when the provided fields don't make a valid date" do
      # Can't use factories as we have to trigger the after_initialize method at correct time
      let(:key_person) { KeyPerson.new(dob_day: 31, dob_month: 2, dob_year: 2000) }

      it "should return nil when setting date of birth" do
        expect(key_person.date_of_birth).to eq(nil)
      end
    end
  end
end
