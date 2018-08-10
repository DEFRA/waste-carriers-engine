require "rails_helper"

module WasteCarriersEngine
  RSpec.describe KeyPerson, type: :model do
    describe "#dob" do
      context "when the provided fields make a valid date" do
        # Can't use factories as we have to trigger the after_initialize method at correct time
        let(:key_person) { KeyPerson.new(dob_day: 1, dob_month: 2, dob_year: 2000) }

        it "should return the date when setting date of birth" do
          expect(key_person.dob).to eq(Date.new(key_person.dob_year,
                                                key_person.dob_month,
                                                key_person.dob_day))
        end
      end

      context "when the provided fields don't make a valid date" do
        # Can't use factories as we have to trigger the after_initialize method at correct time
        let(:key_person) { KeyPerson.new(dob_day: 31, dob_month: 2, dob_year: 2000) }

        it "should return nil when setting date of birth" do
          expect(key_person.dob).to eq(nil)
        end
      end
    end

    describe "conviction_check_required?" do
      context "when there is no conviction_search_result" do
        let(:key_person) { build(:key_person, :has_required_data) }

        it "returns false" do
          expect(key_person.conviction_check_required?).to eq(false)
        end
      end

      context "when there is a matching conviction_search_result" do
        let(:key_person) { build(:key_person,
                                 :has_required_data,
                                 :matched_conviction_search_result) }

        it "returns true" do
          expect(key_person.conviction_check_required?).to eq(true)
        end
      end

      context "when there is a non-matching conviction_search_result" do
        let(:key_person) { build(:key_person,
                                 :has_required_data,
                                 :unmatched_conviction_search_result) }

        it "returns false" do
          expect(key_person.conviction_check_required?).to eq(false)
        end
      end

      context "when there is an unknwon conviction_search_result" do
        let(:key_person) { build(:key_person,
                                 :has_required_data,
                                 :unknown_conviction_search_result) }

        it "returns true" do
          expect(key_person.conviction_check_required?).to eq(true)
        end
      end
    end
  end
end
