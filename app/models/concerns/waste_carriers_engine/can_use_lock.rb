# frozen_string_literal: true

# Warning: Do not extend it in TransientRegistration.
# The Mongoid::Locker gem has trouble dealing with STI and it will cause errors.
module WasteCarriersEngine
  module CanUseLock
    extend ActiveSupport::Concern

    include Mongoid::Document

    included do
      # Including mongoId::Locker outside of this will generate errors when using the lock.
      # Reason unknow for now.
      include Mongoid::Locker

      field :locking_name, type: String
      field :locked_at, type: Time

      index(
        { _id: 1, locking_name: 1 },
        name: "mongoid_locker_index",
        sparse: true,
        unique: true,
        expire_after_seconds: 20
      )
    end
  end
end
