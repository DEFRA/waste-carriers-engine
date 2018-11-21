# frozen_string_literal: true

module WasteCarriersEngine
  class ConvictionSignOff
    include Mongoid::Document
    include CanChangeConvictionWorkflowStatus

    embedded_in :registration,      class_name: "WasteCarriersEngine::Registration"
    embedded_in :past_registration, class_name: "WasteCarriersEngine::PastRegistration"

    field :confirmed,                       type: String
    field :confirmedAt, as: :confirmed_at,  type: DateTime
    field :confirmedBy, as: :confirmed_by,  type: String

    def approve(current_user)
      sign_off(current_user)
      save!
    end
  end
end
