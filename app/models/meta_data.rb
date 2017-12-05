class MetaData
  include Mongoid::Document
  include CanChangeStatus

  embedded_in :registration

  field :status,                                type: String
  field :route,                                 type: String
  field :dateRegistered, as: :date_registered,  type: DateTime
  field :dateActivated, as: :date_activated,    type: DateTime
  field :anotherString, as: :another_string,    type: String # Not sure if this is needed
  field :lastModified, as: :last_modified,      type: DateTime
  field :revokedReason, as: :revoked_reason,    type: String
  field :distance,                              type: String # This appears to always be n/a. What is this for?

  validates :status,
            presence: true
end
