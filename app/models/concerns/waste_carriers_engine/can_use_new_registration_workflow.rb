# frozen_string_literal: true

module WasteCarriersEngine
  module CanUseNewRegistrationWorkflow
    extend ActiveSupport::Concern
    include Mongoid::Document

    included do
      include AASM

      field :workflow_state, type: String

      aasm column: :workflow_state do
        state :start_form, initial: true
      end
    end
  end
end
