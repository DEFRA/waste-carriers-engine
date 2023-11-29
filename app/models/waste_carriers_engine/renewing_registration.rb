# frozen_string_literal: true

module WasteCarriersEngine
  class RenewingRegistration < TransientRegistration
    include CanCheckIfRegistrationTypeChanged
    include CanCopyDataFromRegistration
    include CanUseRenewingRegistrationWorkflow
    include CanUseLock

    validate :no_renewal_in_progress?, on: :create
    validates :reg_identifier, "waste_carriers_engine/reg_identifier": true

    field :from_magic_link, type: Boolean

    COPY_DATA_OPTIONS = {
      ignorable_attributes: %w[_id
                               accountEmail
                               constructionWaste
                               contactEmail
                               conviction_search_result
                               conviction_sign_offs
                               copy_cards
                               declaration
                               declaredConvictions
                               deregistration_token
                               deregistration_token_created_at
                               isMainService
                               firstName
                               financeDetails
                               key_people
                               lastName
                               onlyAMF
                               otherBusinesses
                               past_registrations
                               phoneNumber
                               receipt_email
                               renew_token],
      remove_revoked_reason: true
    }.freeze

    SUBMITTED_STATES = %w[renewal_complete_form
                          renewal_received_pending_conviction_form
                          renewal_received_pending_payment_form].freeze

    def registration
      @_registration ||= Registration.find_by(reg_identifier: reg_identifier)
    end

    def fee_including_possible_type_change
      if registration_type_changed?
        Rails.configuration.renewal_charge + Rails.configuration.type_change_charge
      else
        Rails.configuration.renewal_charge
      end
    end

    def projected_renewal_end_date
      return unless expires_on.present?

      ExpiryCheckService.new(self).expiry_date_after_renewal
    end

    def pending_payment?
      renewal_application_submitted? && super
    end

    def prepare_for_payment(mode, user)
      FinanceDetails.new_renewal_finance_details(self, mode, user)
    end

    def renewal_application_submitted?
      SUBMITTED_STATES.include?(workflow_state)
    end

    def can_be_renewed?
      return false unless %w[ACTIVE EXPIRED].include?(metaData.status)

      # The only time an expired registration can be renewed is if the
      # application
      # - has a confirmed declaration i.e. user reached the copy cards page
      # - it is within the grace window
      return true if declaration_confirmed?

      check_service = ExpiryCheckService.new(self)
      return true if check_service.in_expiry_grace_window?
      return false if check_service.expired?

      check_service.in_renewal_window?
    end

    def ready_to_complete?
      # Though both pending_payment? and pending_manual_conviction_check? also
      # check that the renewal has been submitted, if it hasn't they would both
      # return false, which would mean we would not stop the renewal from
      # completing. Hence we have to check it separately first
      return false unless renewal_application_submitted?
      return false if pending_payment?
      return false if pending_manual_conviction_check?

      true
    end

    def stuck?
      return false unless renewal_application_submitted?
      return false if revoked?
      return false if pending_payment? || pending_manual_conviction_check?

      true
    end

    def pending_manual_conviction_check?
      renewal_application_submitted? && super
    end

    def original_registration_date
      registration.original_registration_date
    end

    def original_activation_date
      registration.original_activation_date
    end

    private

    # Check if a transient renewal already exists for this registration so we don't have
    # multiple renewals in progress at once
    def no_renewal_in_progress?
      return false unless RenewingRegistration.where(reg_identifier: reg_identifier).exists?

      errors.add(:reg_identifier, :renewal_in_progress)
    end

    def registration_type_base_charges
      charges = [Rails.configuration.renewal_charge]
      charges << Rails.configuration.type_change_charge if registration_type_changed?

      charges
    end
  end
end
