# frozen_string_literal: true

module WasteCarriersEngine
  module CanUseLock
    extend ActiveSupport::Concern

    include Mongoid::Document
    include Mongoid::Locker

    included do
      field :locking_name, type: String
      field :locked_at, type: Time

      index({ _id: 1, locking_name: 1 }, name: 'mongoid_locker_index', sparse: true, unique: true, expire_after_seconds: 20)
    end
  end
end
