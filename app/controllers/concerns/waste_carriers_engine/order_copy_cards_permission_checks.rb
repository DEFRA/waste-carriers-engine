# frozen_string_literal: true

module WasteCarriersEngine
  module OrderCopyCardsPermissionChecks
    extend ActiveSupport::Concern

    def setup_checks_pass?
      transient_registration_is_valid? && user_has_permission? && registation_is_active? && state_is_correct?
    end

    # Guards
    def user_has_permission?
      return true if can? :order_copy_cards, @transient_registration.registration

      redirect_to page_path("permission")
      false
    end

    def registation_is_active?
      return true if @transient_registration.registration.active?

      redirect_to page_path("invalid")
      false
    end
  end
end
