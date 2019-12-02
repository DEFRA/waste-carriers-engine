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
    end
  end
end
