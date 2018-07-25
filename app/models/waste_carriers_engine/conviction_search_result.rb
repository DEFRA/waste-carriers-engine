module WasteCarriersEngine
  class ConvictionSearchResult
    include Mongoid::Document

    embedded_in :registration,      class_name: "WasteCarriersEngine::Registration"
    embedded_in :past_registration, class_name: "WasteCarriersEngine::PastRegistration"
    embedded_in :key_person,         class_name: "WasteCarriersEngine::KeyPerson"

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

      result.match_result = data["match_result"]
      result.matching_system = data["matching_system"]
      result.reference = data["reference"]
      result.matched_name = data["matched_name"]
      result.searched_at = data["searched_at"]
      result.confirmed = data["confirmed"]

      result
    end
  end
end
