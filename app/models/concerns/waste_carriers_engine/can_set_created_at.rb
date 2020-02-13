# frozen_string_literal: true

module WasteCarriersEngine
  module CanSetCreatedAt
    extend ActiveSupport::Concern
    include Mongoid::Document

    included do
      field :created_at, type: DateTime

      before_create :update_created_at
    end

    private

    def update_created_at
      self.created_at = Time.current
    end
  end
end
