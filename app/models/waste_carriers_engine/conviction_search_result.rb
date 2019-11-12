# frozen_string_literal: true

module WasteCarriersEngine
  class ConvictionSearchResult
    include Mongoid::Document

    embedded_in :registration,      class_name: "WasteCarriersEngine::Registration"
    embedded_in :past_registration, class_name: "WasteCarriersEngine::PastRegistration"
    embedded_in :key_person,        class_name: "WasteCarriersEngine::KeyPerson"

    field :match_result,    type: String
    field :matching_system, type: String
    field :reference,       type: String
    field :matched_name,    type: String
    field :searched_at,     type: DateTime
    field :confirmed,       type: String
    field :confirmed_at,    type: DateTime
    field :confirmed_by,    type: String

    def self.new_from_entity_matching_service(data)
      result = ConvictionSearchResult.new

      valid_keys = %i[match_result
                      matching_system
                      reference
                      matched_name
                      searched_at
                      confirmed]
      result.attributes = data.slice(*valid_keys)

      result
    end
  end
end
