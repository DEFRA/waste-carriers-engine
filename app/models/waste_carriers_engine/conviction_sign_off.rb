module WasteCarriersEngine
  class ConvictionSignOff
    include Mongoid::Document

    embedded_in :registration,      class_name: "WasteCarriersEngine::Registration"
    embedded_in :past_registration, class_name: "WasteCarriersEngine::PastRegistration"

    field :confirmed,                       type: Boolean
    field :confirmedAt, as: :confirmed_at,  type: DateTime
    field :confirmedBy, as: :confirmed_by,  type: String
  end
end
