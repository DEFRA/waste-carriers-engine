module WasteCarriersEngine
  class ConvictionSearchResult
    include Mongoid::Document

    embedded_in :registration,      class_name: "WasteCarriersEngine::Registration"
    embedded_in :past_registration, class_name: "WasteCarriersEngine::PastRegistration"
    embedded_in :keyPerson,         class_name: "WasteCarriersEngine::KeyPerson"

    field :matchResult, as: :match_result,        type: String
    field :matchingSystem, as: :matching_system,  type: String
    field :reference,                             type: String
    field :matchedName, as: :matched_name,        type: String
    field :searchedAt, as: :searched_at,          type: DateTime
    field :confirmed,                             type: String
    field :confirmedAt, as: :confirmed_at,        type: DateTime
    field :confirmedBy, as: :confirmed_by,        type: String

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
