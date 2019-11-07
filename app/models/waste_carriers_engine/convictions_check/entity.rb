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

      scope :matching_name, lambda { |term|
        escaped_term = ::Regexp.escape(term) if term.present?

        where(name: /#{escaped_term}/i)
      }

      scope :matching_date_of_birth, lambda { |term|
        where(date_of_birth: term)
      }

      scope :matching_company_number, lambda { |term|
        escaped_term = ::Regexp.escape(term) if term.present?

        where(company_number: /#{escaped_term}/i)
      }

      def self.matching_organisations(name:, company_no: nil)
        results = matching_name(name) + matching_company_number(company_no)
        results.uniq
      end

      def self.matching_people(name:, date_of_birth:)
        results = matching_name(name) + matching_date_of_birth(date_of_birth)
        results.uniq
      end
    end
  end
end
