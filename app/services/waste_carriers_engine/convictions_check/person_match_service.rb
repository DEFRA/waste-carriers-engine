# frozen_string_literal: true

module WasteCarriersEngine
  module ConvictionsCheck
    class PersonMatchService < BaseMatchService
      private

      def assign_search_params(first_name:, last_name:, date_of_birth:)
        @first_name = first_name
        @last_name = last_name
        @date_of_birth = date_of_birth
      end

      def matching_entities
        @_matching_entities ||= Entity.matching_people(first_name: @first_name,
                                                       last_name: @last_name,
                                                       date_of_birth: @date_of_birth)
      end
    end
  end
end
