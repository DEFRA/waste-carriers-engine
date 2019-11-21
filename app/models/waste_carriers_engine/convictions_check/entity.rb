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
        name_matches = matching_person_name(first_name: first_name, last_name: last_name)
        name_and_dob_matches = name_matches.matching_date_of_birth(date_of_birth)

        if name_and_dob_matches.present?
          name_and_dob_matches
        else
          name_matches
        end
      }

      def self.matching_organisations(name:, company_no: nil)
        raise ArgumentError if name.blank?

        results = []
        results += matching_company_number(company_no) if company_no.present?
        results += matching_organisation_name(name)

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

        # The steps for processing the org name must be done in this order:

        # 1. Remove trailing full stops
        without_full_stops = term.gsub(/\.$/, "")
        # 2. Remove common org words
        without_org_words = term_without_ignorable_org_words(without_full_stops)
        # 3. Escape special characters for regex
        escaped = ::Regexp.escape(without_org_words)
        # 4. Treat punctuation as optional when matching
        term_with_optional_punctuation(escaped)
      end

      private_class_method def self.term_without_ignorable_org_words(term)
        word_array = term.downcase.split(" ")
        word_array.reject! { |word| IGNORABLE_ORG_NAME_WORDS.include?(word) }
        word_array.join(" ")
      end

      private_class_method def self.term_with_optional_punctuation(term)
        # These are characters we want to treat as optional
        optional_characters = %w[. , / # ! $ % ^ & * ; : { } = - _ ` ~ ( )]

        chars_array = term.scan(/./)
        chars_array.each_with_index do |char, index|
          chars_array[index] = "#{char}?" if optional_characters.include?(char)
        end

        chars_array.join
      end
    end
  end
end
