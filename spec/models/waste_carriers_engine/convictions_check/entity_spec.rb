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
        end
      end
    end
  end
end
