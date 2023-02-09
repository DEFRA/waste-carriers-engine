# frozen_string_literal: true

module WasteCarriersEngine
  class MetaData
    include Mongoid::Document
    include CanChangeRegistrationStatus

    embedded_in :registration,           class_name: "WasteCarriersEngine::Registration"
    embedded_in :past_registration,      class_name: "WasteCarriersEngine::PastRegistration"
    embedded_in :transient_registration, class_name: "WasteCarriersEngine::TransientRegistration"

    field :route,                                      type: String
    field :dateRegistered, as: :date_registered,       type: DateTime
    field :dateActivated, as: :date_activated,         type: DateTime
    field :dateDeactivated, as: :date_deactivated,     type: DateTime
    field :anotherString, as: :another_string,         type: String
    field :lastModified, as: :last_modified,           type: DateTime
    field :revokedReason, as: :revoked_reason,         type: String
    field :deactivatedBy, as: :deactivated_by,         type: String
    field :deactivationRoute, as: :deactivation_route, type: String

    validates :status, presence: true

    def initialize(params = nil)
      super(params)

      self.route = Rails.configuration.metadata_route
    end
  end
end
