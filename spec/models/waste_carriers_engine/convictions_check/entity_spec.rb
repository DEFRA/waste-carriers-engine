# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  module ConvictionsCheck
    RSpec.describe Entity, type: :model do
      describe "public interface" do
        properties = %i[name date_of_birth company_number system_flag incident_number]

        properties.each do |property|
          it "responds to property" do
            expect(subject).to respond_to(property)
          end
        end
      end

      describe "scopes" do
        let(:term) { "foo" }
        let(:matching_first_name) { "foo" }
        let(:matching_last_name) { "bar" }
        let(:non_matching_term) { "baz" }

        describe "#matching_organisation_name" do
          let(:scope) { described_class.matching_organisation_name(term) }

          it "returns records with matching names" do
            matching_record = described_class.create(name: term)
            partially_matching_record = described_class.create(name: "#{term} waste")
            non_matching_record = described_class.create(name: non_matching_term)

            expect(scope).to include(matching_record)
            expect(scope).to include(partially_matching_record)
            expect(scope).to_not include(non_matching_record)
          end

          it "is not case sensitive" do
            upcased_record = described_class.create(name: term.upcase)

            expect(scope).to include(upcased_record)
          end

          context "when the search term ends with a ." do
            let(:term) { "foo." }

            it "treats the . as an optional match" do
              record_with_trailing_full_stop = described_class.create(name: "foo.")
              record_without_trailing_full_stop = described_class.create(name: "foo")
              record_with_full_stop_somewhere_else = described_class.create(name: "f.oo")

              expect(scope).to include(record_with_trailing_full_stop)
              expect(scope).to include(record_without_trailing_full_stop)
              expect(scope).to_not include(record_with_full_stop_somewhere_else)
            end
          end

          context "when the search term contains ignorable words" do
            let(:term) { "foo ltd" }

            it "does not require them to match" do
              record_with_exact_name = described_class.create(name: "foo ltd")
              record_without_common_word = described_class.create(name: "foo")
              record_with_different_common_word = described_class.create(name: "foo limited")

              expect(scope).to include(record_with_exact_name)
              expect(scope).to include(record_without_common_word)
              expect(scope).to include(record_with_different_common_word)
            end
          end

          context "when the search term has special characters" do
            let(:matching_first_name) { "*" }

            it "does not break the scope" do
              expect { scope }.to_not raise_error
            end
          end

          context "when the search term is blank" do
            let(:term) { nil }

            it "raises an error" do
              expect { scope }.to raise_error(ArgumentError)
            end
          end
        end

        describe "#matching_person_name" do
          let(:scope) { described_class.matching_person_name(first_name: matching_first_name, last_name: matching_last_name) }

          it "returns records with matching first names and last names" do
            matching_record = described_class.create(name: "#{matching_last_name}, #{matching_first_name}")
            non_matching_record = described_class.create(name: non_matching_term)

            expect(scope).to include(matching_record)
            expect(scope).to_not include(non_matching_record)
          end

          it "does not return records where only the first name matches" do
            non_matching_record = described_class.create(name: "#{non_matching_term}, #{matching_first_name}")

            expect(scope).to_not include(non_matching_record)
          end

          it "does not return records where only the last name matches" do
            non_matching_record = described_class.create(name: "#{matching_last_name}, #{non_matching_term}")

            expect(scope).to_not include(non_matching_record)
          end

          it "is not case sensitive" do
            upcased_record = described_class.create(name: "#{matching_last_name}, #{matching_first_name}".upcase)

            expect(scope).to include(upcased_record)
          end

          context "when the search term has special characters" do
            let(:matching_first_name) { "*" }

            it "does not break the scope" do
              expect { scope }.to_not raise_error
            end
          end

          context "when the search terms are blank" do
            let(:matching_first_name) { nil }
            let(:matching_last_name) { nil }

            it "raises an error" do
              expect { scope }.to raise_error(ArgumentError)
            end
          end
        end

        describe "#matching_date_of_birth" do
          let(:scope) { described_class.matching_date_of_birth(term) }

          let(:term) { Date.today }
          let(:non_matching_term) { Date.yesterday }

          it "returns records with matching date_of_births" do
            matching_record = described_class.create(date_of_birth: term)
            non_matching_record = described_class.create(date_of_birth: non_matching_term)

            expect(scope).to include(matching_record)
            expect(scope).to_not include(non_matching_record)
          end

          context "when the search term is blank" do
            let(:term) { nil }

            it "raises an error" do
              expect { scope }.to raise_error(ArgumentError)
            end
          end

          context "when the search term is not a date" do
            let(:term) { "foo" }

            it "raises an error" do
              expect { scope }.to raise_error(ArgumentError)
            end
          end
        end

        describe "#matching_company_number" do
          let(:scope) { described_class.matching_company_number(term) }

          it "returns records with exactly matching company_numbers" do
            matching_record = described_class.create(company_number: term)
            partially_matching_record = described_class.create(company_number: "#{term}A")
            non_matching_record = described_class.create(company_number: non_matching_term)

            expect(scope).to include(matching_record)
            expect(scope).to_not include(partially_matching_record)
            expect(scope).to_not include(non_matching_record)
          end

          it "is not case sensitive" do
            upcased_record = described_class.create(company_number: term.upcase)

            expect(scope).to include(upcased_record)
          end

          context "when the search term starts with a 0" do
            let(:term) { "01234567" }

            it "treats the zero as an optional match" do
              record_with_leading_zero = described_class.create(company_number: "01234567")
              record_without_leading_zero = described_class.create(company_number: "1234567")
              record_with_zero_somewhere_else = described_class.create(company_number: "10234567")

              expect(scope).to include(record_with_leading_zero)
              expect(scope).to include(record_without_leading_zero)
              expect(scope).to_not include(record_with_zero_somewhere_else)
            end
          end

          context "when the search term has special characters" do
            let(:term) { "*" }

            it "does not break the scope" do
              expect { scope }.to_not raise_error
            end
          end

          context "when the search term is blank" do
            let(:term) { nil }

            it "raises an error" do
              expect { scope }.to raise_error(ArgumentError)
            end
          end
        end

        describe "#matching_people" do
          let(:term) { "foo" }
          let(:non_matching_term) { "bar" }
          let(:date_term) { Date.today }
          let(:non_matching_date_term) { Date.yesterday }

          let(:scope) { described_class.matching_people(first_name: term, last_name: term, date_of_birth: date_term) }

          it "only returns records where both the name and date_of_birth match" do
            matching_record = described_class.create(name: "#{term} #{term}", date_of_birth: date_term)
            name_match_only_record = described_class.create(name: "#{term} #{term}", date_of_birth: non_matching_date_term)
            dob_match_only_record = described_class.create(name: non_matching_term, date_of_birth: date_term)
            non_matching_record = described_class.create(name: non_matching_term, date_of_birth: non_matching_date_term)

            expect(scope).to include(matching_record)
            expect(scope).to_not include(name_match_only_record)
            expect(scope).to_not include(dob_match_only_record)
            expect(scope).to_not include(non_matching_record)
          end

          context "when the name is blank" do
            let(:term) { nil }

            it "raises an error" do
              expect { scope }.to raise_error(ArgumentError)
            end
          end

          context "when the date_of_birth is blank" do
            let(:date_term) { nil }

            it "raises an error" do
              expect { scope }.to raise_error(ArgumentError)
            end
          end
        end
      end

      describe "#matching_organisations" do
        let(:term) { "foo" }
        let(:non_matching_term) { "bar" }

        let(:results) { described_class.matching_organisations(name: term, company_no: term) }

        it "returns records with matching names" do
          matching_record = described_class.create(name: term)
          non_matching_record = described_class.create(name: non_matching_term)

          expect(results).to include(matching_record)
          expect(results).to_not include(non_matching_record)
        end

        it "returns records with matching company_numbers" do
          matching_record = described_class.create(company_number: term)
          non_matching_record = described_class.create(company_number: non_matching_term)

          expect(results).to include(matching_record)
          expect(results).to_not include(non_matching_record)
        end

        it "does not return records with matching date_of_births" do
          term = Date.today
          non_matching_term = Date.yesterday

          matching_record = described_class.create(date_of_birth: term)
          non_matching_record = described_class.create(date_of_birth: non_matching_term)

          expect(results).to_not include(matching_record)
          expect(results).to_not include(non_matching_record)
        end

        it "allows company_no to be missing" do
          expect { described_class.matching_organisations(name: term) }.to_not raise_error
        end

        it "does not allow name to be missing" do
          expect { described_class.matching_organisations(company_no: term) }.to raise_error { ArgumentError }
        end

        context "when the name is blank" do
          let(:term) { nil }

          it "raises an error" do
            expect { results }.to raise_error(ArgumentError)
          end
        end
      end
    end
  end
end
