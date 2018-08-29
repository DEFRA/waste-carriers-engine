module WasteCarriersEngine
  class ConvictionSignOff
    include Mongoid::Document

    embedded_in :registration,      class_name: "WasteCarriersEngine::Registration"
    embedded_in :past_registration, class_name: "WasteCarriersEngine::PastRegistration"

    field :confirmed,                       type: String
    field :confirmedAt, as: :confirmed_at,  type: DateTime
    field :confirmedBy, as: :confirmed_by,  type: String

    def approve(current_user)
      self.confirmed = "yes"
      self.confirmed_at = Time.current
      self.confirmed_by = current_user.email

      save!
    end
  end
end
