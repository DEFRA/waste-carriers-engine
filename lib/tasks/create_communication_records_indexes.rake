# frozen_string_literal: true

# one-off task to create db index for notification_id on the communication_records collection
namespace :one_off do
  desc "Create the notification_id index on the communication_records collection"
  task create_communication_records_indexes: :environment do
    WasteCarriersEngine::CommunicationRecord.collection.indexes.create_one(
      { notification_id: 1 },
      background: true
    )
  end
end
