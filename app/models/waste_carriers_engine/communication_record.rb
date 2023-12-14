# frozen_string_literal: true

module WasteCarriersEngine
  class CommunicationRecord
    include Mongoid::Document

    field :registration_id, type: BSON::ObjectId
    field :notify_template_id, type: String
    field :notification_type, type: String
    field :comms_label, type: String
    field :sent_at, type: DateTime

    belongs_to :registration
  end
end
