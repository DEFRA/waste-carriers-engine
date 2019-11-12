# frozen_string_literal: true

module WasteCarriersEngine
  module ConvictionsCheck
    class BaseMatchService < BaseService
      def run(*args)
        assign_search_params(*args)
        check_for_matches_and_return_data
      end

      private

      def assign_search_params(_args)
        raise NotImplementedError
      end

      def check_for_matches_and_return_data
        if matching_entities.any?
          positive_match(matching_entities.first)
        else
          negative_match
        end
      rescue ArgumentError
        error_match
      end

      def matching_entities
        raise NotImplementedError
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
