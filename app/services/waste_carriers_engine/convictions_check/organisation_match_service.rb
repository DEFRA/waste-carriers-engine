# frozen_string_literal: true

module WasteCarriersEngine
  module ConvictionsCheck
    class OrganisationMatchService < BaseMatchService
      private

      def assign_search_params(name:, company_no:)
        @name = name
        @company_no = company_no
      end

      def matching_entities
        @_matching_entities ||= Entity.matching_organisations(name: @name,
                                                              company_no: @company_no)
      end
    end
  end
end
