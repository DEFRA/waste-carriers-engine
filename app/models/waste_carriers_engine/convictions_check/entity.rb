# frozen_string_literal: true

module WasteCarriersEngine
  module ConvictionsCheck
    class Entity
      include Mongoid::Document

      store_in collection: "entities"

      # The full name, either of an organisation or an individual
      field :name,                                 type: String
      # Only used for individuals - may not be known or available
      field :dateOfBirth, as: :date_of_birth,      type: Date
      # Only used for organisations, if applicable
      field :companyNumber, as: :company_number,   type: String
      # The system where the match is from
      field :systemFlag, as: :system_flag,         type: String
      # The incident number or reference code
      field :incidentNumber, as: :incident_number, type: String

      scope :matching_organisation_name, lambda { |term|
        term = ::Regexp.escape(term) if term.present?

        where(name: /#{term}/i)
      }

      scope :matching_person_name, lambda { |first_name:, last_name:|
        escaped_first_name = ::Regexp.escape(first_name) if first_name.present?
        escaped_last_name = ::Regexp.escape(last_name) if last_name.present?

        where(name: /#{escaped_first_name}/i).and(name: /#{escaped_last_name}/i)
      }

      scope :matching_date_of_birth, lambda { |term|
        where(date_of_birth: term)
      }

      scope :matching_company_number, lambda { |term|
        escaped_term = ::Regexp.escape(term) if term.present?
        # If the company_no starts with a 0, treat that 0 as optional in the regex
        term_with_optional_starting_zero = escaped_term.gsub(/^0/, "0?") if escaped_term.present?

        where(company_number: /#{term_with_optional_starting_zero}/i)
      }

      scope :matching_people, lambda { |first_name:, last_name:, date_of_birth:|
        matching_person_name(first_name: first_name, last_name: last_name).matching_date_of_birth(date_of_birth)
      }

      def self.matching_organisations(name:, company_no: nil)
        results = matching_organisation_name(name) + matching_company_number(company_no)
        results.uniq
      end
    end
  end
end
