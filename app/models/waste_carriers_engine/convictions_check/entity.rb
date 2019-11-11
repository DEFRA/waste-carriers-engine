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
        raise ArgumentError if term.blank?

        where(name: /#{org_name_search_term(term)}/i)
      }

      scope :matching_person_name, lambda { |first_name:, last_name:|
        raise ArgumentError if first_name.blank? || last_name.blank?

        escaped_first_name = ::Regexp.escape(first_name)
        escaped_last_name = ::Regexp.escape(last_name)

        where(name: /#{escaped_first_name}/i).and(name: /#{escaped_last_name}/i)
      }

      scope :matching_date_of_birth, lambda { |term|
        raise ArgumentError unless term.is_a?(Date)

        where(date_of_birth: term)
      }

      scope :matching_company_number, lambda { |term|
        raise ArgumentError if term.blank?

        escaped_term = ::Regexp.escape(term)
        # If the company_no starts with a 0, treat that 0 as optional in the regex
        term_with_optional_starting_zero = escaped_term.gsub(/^0/, "0?")

        where(company_number: /^#{term_with_optional_starting_zero}$/i)
      }

      scope :matching_people, lambda { |first_name:, last_name:, date_of_birth:|
        matching_person_name(first_name: first_name, last_name: last_name).matching_date_of_birth(date_of_birth)
      }

      def self.matching_organisations(name:, company_no: nil)
        raise ArgumentError if name.blank?

        results = matching_organisation_name(name)

        return results unless company_no.present?

        results += matching_company_number(company_no)
        results.uniq
      end

      private

      # We want to ignore certain common words for the purposes of name matching.
      # This includes company types and suffixes, and major locations.
      # This is so a name like "Bobby's Bins Ltd" will still match "Bobby's Bins
      # Limited" or just "Bobby's Bins".
      IGNORABLE_ORG_NAME_WORDS = %w[
        limited ltd plc inc incorporated llp lp company
        co holdings investments services technologies solutions
        group cyf cyfyngedig ccc cic cio ag corp eurl
        gmbh sa sarl sp prc partners lc
        uk gb europe intl international england wales
        scotland cymru
      ].freeze

      private_class_method def self.org_name_search_term(term)
        return if term.blank?

        # Trim trailing full stops
        term_without_trailing_full_stops = term.gsub(/\.$/, "")

        # Remove the words we want to ignore
        word_array = term_without_trailing_full_stops.downcase.split(" ")
        word_array.reject! { |word| IGNORABLE_ORG_NAME_WORDS.include?(word) }
        term_without_ignorable_words = word_array.join(" ")

        ::Regexp.escape(term_without_ignorable_words)
      end
    end
  end
end
