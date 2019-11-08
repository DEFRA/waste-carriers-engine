# frozen_string_literal: true

require "rest-client"

module WasteCarriersEngine
  module ConvictionsCheck
    class PersonMatchService < BaseService
      def run(first_name:, last_name:, date_of_birth:)
        Entity.matching_people(first_name: first_name,
                               last_name: last_name,
                               date_of_birth: date_of_birth)
      end
    end
  end
end
