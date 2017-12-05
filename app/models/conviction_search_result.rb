class ConvictionSearchResult
  include Mongoid::Document

  embedded_in :registration
  embedded_in :keyPerson

  field :matchResult, as: :match_result,        type: String
  field :matchingSystem, as: :matching_system,  type: String
  field :reference,                             type: String
  field :matchedName, as: :matched_name,        type: String
  field :searchedAt, as: :searched_at,          type: DateTime
  field :confirmed,                             type: Boolean
  field :confirmedAt, as: :confirmed_at,        type: DateTime
  field :confirmedBy, as: :confirmed_by,        type: String
end
