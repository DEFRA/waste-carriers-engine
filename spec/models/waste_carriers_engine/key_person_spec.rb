# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe KeyPerson do
    context "with initialization" do
      describe "#set_individual_dob_fields" do
        context "when there is a valid dob" do
          let(:key_person) { described_class.new(dob: Date.new(2000, 2, 1)) }

          it "assigns the correct values to the individual fields" do
            expect(key_person.dob_year).to eq(2000)
            expect(key_person.dob_month).to eq(2)
            expect(key_person.dob_day).to eq(1)
          end
        end

        context "when there is not a valid dob" do
          let(:key_person) { described_class.new }

          it "does not assign values to the individual fields" do
            expect(key_person.dob_day).to be_nil
            expect(key_person.dob_month).to be_nil
            expect(key_person.dob_year).to be_nil
          end
        end
      end

      describe "#set_date_of_birth" do
        context "when the provided fields make a valid date" do
          # Can't use factories as we have to trigger the after_initialize method at correct time
          let(:key_person) { described_class.new(dob_day: 1, dob_month: 2, dob_year: 2000) }

          it "returns the date when setting date of birth" do
            expect(key_person.dob).to eq(Date.new(key_person.dob_year,
                                                  key_person.dob_month,
                                                  key_person.dob_day))
          end
        end

        context "when the provided fields don't make a valid date" do
          # Can't use factories as we have to trigger the after_initialize method at correct time
          let(:key_person) { described_class.new(dob_day: 31, dob_month: 2, dob_year: 2000) }

          it "returns nil when setting date of birth" do
            expect(key_person.dob).to be_nil
          end
        end
      end
    end

    describe "conviction_check_required?" do
      context "when there is no conviction_search_result" do
        let(:key_person) { build(:key_person, :has_required_data) }

        it "returns false" do
          expect(key_person.conviction_check_required?).to be false
        end
      end

      context "when there is a matching conviction_search_result" do
        let(:key_person) do
          build(:key_person,
                :has_required_data,
                :matched_conviction_search_result)
        end

        it "returns true" do
          expect(key_person.conviction_check_required?).to be true
        end
      end

      context "when there is a non-matching conviction_search_result" do
        let(:key_person) do
          build(:key_person,
                :has_required_data,
                :unmatched_conviction_search_result)
        end

        it "returns false" do
          expect(key_person.conviction_check_required?).to be false
        end
      end

      context "when there is an unknwon conviction_search_result" do
        let(:key_person) do
          build(:key_person,
                :has_required_data,
                :unknown_conviction_search_result)
        end

        it "returns true" do
          expect(key_person.conviction_check_required?).to be true
        end
      end
    end
  end
end
