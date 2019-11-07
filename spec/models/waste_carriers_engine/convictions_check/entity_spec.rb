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
        let(:non_matching_term) { "bar" }

        describe "#matching_name" do
          let(:scope) { described_class.matching_name(term) }

          it "returns records with matching names" do
            matching_record = described_class.create(name: term)
            non_matching_record = described_class.create(name: non_matching_term)

            expect(scope).to include(matching_record)
            expect(scope).to_not include(non_matching_record)
          end

          it "is not case sensitive" do
            upcased_record = described_class.create(name: term.upcase)

            expect(scope).to include(upcased_record)
          end

          context "when the search term has special characters" do
            let(:term) { "*" }

            it "does not break the scope" do
              expect { scope }.to_not raise_error
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
        end

        describe "#matching_company_number" do
          let(:scope) { described_class.matching_company_number(term) }

          it "returns records with matching company_numbers" do
            matching_record = described_class.create(company_number: term)
            non_matching_record = described_class.create(company_number: non_matching_term)

            expect(scope).to include(matching_record)
            expect(scope).to_not include(non_matching_record)
          end

          it "is not case sensitive" do
            upcased_record = described_class.create(company_number: term.upcase)

            expect(scope).to include(upcased_record)
          end

          context "when the search term has special characters" do
            let(:term) { "*" }

            it "does not break the scope" do
              expect { scope }.to_not raise_error
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
      end

      describe "#matching_people" do
        let(:term) { "foo" }
        let(:non_matching_term) { "bar" }
        let(:date_term) { Date.today }
        let(:non_matching_date_term) { Date.yesterday }

        let(:results) { described_class.matching_people(name: term, date_of_birth: date_term) }

        it "returns records with matching names" do
          matching_record = described_class.create(name: term)
          non_matching_record = described_class.create(name: non_matching_term)

          expect(results).to include(matching_record)
          expect(results).to_not include(non_matching_record)
        end

        it "returns records with matching date_of_births" do
          matching_record = described_class.create(date_of_birth: date_term)
          non_matching_record = described_class.create(date_of_birth: non_matching_date_term)

          expect(results).to include(matching_record)
          expect(results).to_not include(non_matching_record)
        end

        it "does not return records with matching company_numbers" do
          matching_record = described_class.create(company_number: term)
          non_matching_record = described_class.create(company_number: non_matching_term)

          expect(results).to_not include(matching_record)
          expect(results).to_not include(non_matching_record)
        end

        it "does not allow name to be missing" do
          expect { described_class.matching_people(date_of_birth: term) }.to raise_error { ArgumentError }
        end

        it "does not allow date_of_birth to be missing" do
          expect { described_class.matching_people(name: term) }.to raise_error { ArgumentError }
        end
      end
    end
  end
end
