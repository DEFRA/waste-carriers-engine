# frozen_string_literal: true

require "rest-client"

module WasteCarriersEngine
  module ConvictionsCheck
    class PersonMatchService < BaseService
      def run(first_name:, last_name:, date_of_birth:)
        @first_name = first_name
        @last_name = last_name
        @date_of_birth = date_of_birth

        begin
          if matching_entities.any?
            positive_match(matching_entities.first)
          else
            false
          end
        rescue ArgumentError
          nil
        end
      end

      private

      def matching_entities
        @_matching_entities ||= Entity.matching_people(first_name: @first_name,
                                                       last_name: @last_name,
                                                       date_of_birth: @date_of_birth)
      end

      def positive_match(entity)
        data = basic_match_data

        data[:match_result] = "YES"
        data[:matching_system] = entity.system_flag
        data[:reference] = entity.incident_number
        data[:matched_name] = entity.name

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
