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
                               otherBusinesses
                               renew_token
                               isMainService
                               constructionWaste
                               onlyAMF
                               addresses
                               key_people
                               financeDetails
                               declaredConvictions
                               conviction_search_result
                               conviction_sign_offs
                               declaration
                               past_registrations
                               copy_cards
                               receipt_email
                               firstName
                               lastName
                               phoneNumber
                               contactEmail],
      remove_revoked_reason: true
    }.freeze

    SUBMITTED_STATES = %w[renewal_complete_form
                          renewal_received_pending_conviction_form
                          renewal_received_pending_payment_form
                          renewal_received_pending_worldpay_payment_form].freeze

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

    def company_no_changed?
      return false unless company_no_required?

      # LLP is a new business type, so users who previously were forced to select 'partnership' would not have had the
      # opportunity to enter a company_no. Therefore we have nothing to compare against and should allow users to
      # continue the renewal journey.
      return false if registration.business_type == "partnership"

      # It was previously possible to save a company_no with excess whitespace. This is no longer possible, but we
      # should ignore this whitespace when comparing, otherwise a trailing space will block the user from renewing their
      # registration.
      old_company_no = registration.company_no.to_s.strip

      # It was previously possible to save a company_no with lowercase letters e.g. ni123456. This is no longer
      # possible because the check against Comapnies House fails when we search with lowercase registration numbers. The
      # value has to be made uppercase. So to avoid the renewal being blocked because it thinks the numbers don't match
      # we upcase the old_company_no
      old_company_no.upcase!

      # It was previously valid to have company_nos with less than 8 digits
      # The form prepends 0s to make up the length, so we should do this for the old number to match
      old_company_no = "0#{old_company_no}" while old_company_no.length < 8
      old_company_no != company_no
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

    private

    # Check if a transient renewal already exists for this registration so we don't have
    # multiple renewals in progress at once
    def no_renewal_in_progress?
      return unless RenewingRegistration.where(reg_identifier: reg_identifier).exists?

      errors.add(:reg_identifier, :renewal_in_progress)
    end

    def registration_type_base_charges
      charges = [Rails.configuration.renewal_charge]
      charges << Rails.configuration.type_change_charge if registration_type_changed?

      charges
    end
  end
end
