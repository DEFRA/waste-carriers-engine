class ConvictionSearchResult
  include Mongoid::Document

  embedded_in :registration
  embedded_in :keyPerson

  # TODO: Confirm types
  field :matchResult,     type: String
  field :matchingSystem,  type: String
  field :reference,       type: String
  field :matchedName,     type: String
  field :searchedAt,      type: DateTime
  field :confirmed,       type: Boolean
  field :confirmedAt,     type: DateTime
  field :confirmedBy,     type: String
end
