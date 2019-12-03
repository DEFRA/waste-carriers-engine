# frozen_string_literal: true

module WasteCarriersEngine
  module CanFilterConvictionStatus
    extend ActiveSupport::Concern

    included do
      scope :convictions_possible_match, lambda {
        where("conviction_sign_offs.0.workflow_state": "possible_match")
      }
      scope :convictions_checks_in_progress, lambda {
        where("conviction_sign_offs.0.workflow_state": "checks_in_progress")
      }
      scope :convictions_approved, lambda {
        where("conviction_sign_offs.0.workflow_state": "approved")
      }
      scope :convictions_rejected, lambda {
        where("conviction_sign_offs.0.workflow_state": "rejected")
      }
      # This is to catch historical conviction_sign_offs which were only created and modified by waste-carriers-frontend
      # and have no workflow_state as a result. We want ones which have not been confirmed and are in a pending state.
      scope :convictions_new_without_status, lambda {
        where(:"conviction_sign_offs.0".exists => true,
              :"conviction_sign_offs.0.workflow_state".exists => false,
              :"conviction_sign_offs.0.confirmed".ne => "yes",
              "metaData.status": "PENDING")
      }
    end
  end
end
