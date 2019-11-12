# frozen_string_literal: true

require "rest-client"

module WasteCarriersEngine
  class EntityMatchingService < BaseService
    def run(transient_registration)
      @transient_registration = transient_registration
      check_business_for_matches
      check_people_for_matches
    end

    private

    def check_business_for_matches
      data = ConvictionsCheck::OrganisationMatchService.run(name: @transient_registration.company_name,
                                                            company_no: @transient_registration.company_no)
      store_match_result(@transient_registration, data)
    end

    def check_people_for_matches
      @transient_registration.key_people.each do |person|
        data = ConvictionsCheck::PersonMatchService.run(first_name: person.first_name,
                                                        last_name: person.last_name,
                                                        date_of_birth: person.dob)
        store_match_result(person, data)
      end
    end

    def store_match_result(entity, data)
      entity.conviction_search_result = ConvictionSearchResult.new_from_entity_matching_service(data)
      entity.save!
    end
  end
end
