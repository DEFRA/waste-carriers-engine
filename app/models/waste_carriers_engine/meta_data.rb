module WasteCarriersEngine
  class MetaData
    include Mongoid::Document
    include CanChangeRegistrationStatus

    embedded_in :registration,      class_name: "WasteCarriersEngine::Registration"
    embedded_in :past_registration, class_name: "WasteCarriersEngine::PastRegistration"

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
