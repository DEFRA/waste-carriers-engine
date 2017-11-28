class MetaData
  include Mongoid::Document
  include CanChangeStatus

  embedded_in :registration

  field :status,          type: String
  field :route,           type: String
  field :dateRegistered,  type: DateTime
  field :dateActivated,   type: DateTime
  field :anotherString,   type: String # Not sure if this is needed
  field :lastModified,    type: DateTime
  field :revokedReason,   type: String
  field :distance,        type: String # This appears to always be n/a. What is this for?

  validates :status,
            presence: true
end
