# frozen_string_literal: true

module WasteCarriersEngine
  class MetaData
    include Mongoid::Document
    include CanChangeRegistrationStatus

    embedded_in :registration
    embedded_in :past_registration

    field :route,                                 type: String
    field :dateRegistered, as: :date_registered,  type: DateTime
    field :dateActivated, as: :date_activated,    type: DateTime
    field :anotherString, as: :another_string,    type: String
    field :lastModified, as: :last_modified,      type: DateTime
    field :revokedReason, as: :revoked_reason,    type: String
    field :distance,                              type: String

    validates :status,
              presence: true
  end
end
