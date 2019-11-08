# frozen_string_literal: true

require "rest-client"

module WasteCarriersEngine
  module ConvictionsCheck
    class OrganisationMatchService < BaseService
      def run(name:, company_no:)
        @name = name
        @company_no = company_no

        begin
          if matching_entities.any?
            positive_match(matching_entities.first)
          else
            negative_match
          end
        rescue ArgumentError
          error_match
        end
      end

      private

      def matching_entities
        @_matching_entities ||= Entity.matching_organisations(name: @name,
                                                              company_no: @company_no)
      end

      def positive_match(entity)
        data = basic_match_data

        data[:match_result] = "YES"
        data[:matching_system] = entity.system_flag
        data[:reference] = entity.incident_number
        data[:matched_name] = entity.name

        data
      end

      def negative_match
        data = basic_match_data

        data[:match_result] = "NO"

        data
      end

      def error_match
        data = basic_match_data

        data[:match_result] = "UNKNOWN"
        data[:matching_system] = "ERROR"

        data
      end

      def basic_match_data
        {
          searched_at: Time.current,
          confirmed: "no",
          confirmed_at: nil,
          confirmed_by: nil
        }
      end
    end
  end
end
