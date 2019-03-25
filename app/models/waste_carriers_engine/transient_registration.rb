# frozen_string_literal: true

module WasteCarriersEngine
  # rubocop:disable Metrics/ClassLength
  class TransientRegistration
    include Mongoid::Document
    include CanChangeWorkflowStatus
    include CanCheckBusinessTypeChanges
    include CanHaveRegistrationAttributes
    include CanStripWhitespace

    store_in collection: "transient_registrations"

    validates :reg_identifier, "waste_carriers_engine/reg_identifier": true
    validate :no_renewal_in_progress?, on: :create

    after_initialize :copy_data_from_registration
    before_save :update_last_modified

    # Attributes specific to the transient object - all others are in CanHaveRegistrationAttributes
    field :temp_cards, type: Integer
    field :temp_company_postcode, type: String
    field :temp_contact_postcode, type: String
    field :temp_os_places_error, type: String # 'yes' or 'no' - should refactor to boolean
    field :temp_payment_method, type: String
    field :temp_tier_check, type: String # 'yes' or 'no' - should refactor to boolean

    scope :search_term, lambda { |term|
      any_of({ reg_identifier: /\A#{term}\z/i },
             { company_name: /#{term}/i },
             { last_name: /#{term}/i },
             "addresses.postcode": /#{term}/i)
    }
    scope :in_progress, -> { where(:workflow_state.nin => %w[renewal_complete_form renewal_received_form]) }
    scope :submitted, -> { where(:workflow_state.in => %w[renewal_complete_form renewal_received_form]) }
    scope :pending_payment, -> { submitted.where(:"financeDetails.balance".gt => 0) }
    scope :pending_approval, -> { submitted.where("conviction_sign_offs.0.confirmed": "no") }

    scope :convictions_possible_match, -> { submitted.where("conviction_sign_offs.0.workflow_state": "possible_match") }
    scope :convictions_checks_in_progress, lambda {
      submitted.where("conviction_sign_offs.0.workflow_state": "checks_in_progress")
    }
    scope :convictions_approved, -> { submitted.where("conviction_sign_offs.0.workflow_state": "approved") }
    scope :convictions_rejected, -> { submitted.where("conviction_sign_offs.0.workflow_state": "rejected") }

    # Check if the user has changed the registration type, as this incurs an additional 40GBP charge
    def registration_type_changed?
      # Don't compare registration types if the new one hasn't been set
      return false unless registration_type

      original_registration_type = Registration.where(reg_identifier: reg_identifier).first.registration_type
      original_registration_type != registration_type
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

    def total_to_pay
      charges = [Rails.configuration.renewal_charge]
      charges << Rails.configuration.type_change_charge if registration_type_changed?
      charges << total_registration_card_charge
      charges.sum
    end

    def total_registration_card_charge
      return 0 unless temp_cards.present?

      temp_cards * Rails.configuration.card_charge
    end

    def company_no_changed?
      return false unless company_no_required?

      registration = Registration.where(reg_identifier: reg_identifier).first
      # LLP is a new business type, so users who previously were forced to select 'partnership' would not have had the
      # opportunity to enter a company_no. Therefore we have nothing to compare against and should allow users to
      # continue the renewal journey.
      return false if registration.business_type == "partnership"

      # It was previously possible to save a company_no with excess whitespace. This is no longer possible, but we
      # should ignore this whitespace when comparing, otherwise a trailing space will block the user from renewing their
      # registration.
      old_company_no = registration.company_no.to_s.strip

      # It was previously valid to have company_nos with less than 8 digits
      # The form prepends 0s to make up the length, so we should do this for the old number to match
      old_company_no = "0#{old_company_no}" while old_company_no.length < 8
      old_company_no != company_no
    end

    def renewal_application_submitted?
      not_in_progress_states = %w[renewal_received_form renewal_complete_form]
      not_in_progress_states.include?(workflow_state)
    end

    def pending_payment?
      renewal_application_submitted? && finance_details.present? && finance_details.balance.positive?
    end

    def pending_worldpay_payment?
      return false unless finance_details.present? &&
                          finance_details.orders.present? &&
                          finance_details.orders.first.present?

      Order.valid_world_pay_status?(:pending, finance_details.orders.first.world_pay_status)
    end

    def pending_manual_conviction_check?
      renewal_application_submitted? && conviction_check_required?
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
      return true if conviction_sign_offs&.first&.rejected?
      return false if pending_payment? || pending_manual_conviction_check?

      true
    end

    private

    def copy_data_from_registration
      # Don't try to get Registration data with an invalid reg_identifier
      return unless valid? && new_record?

      registration = Registration.where(reg_identifier: reg_identifier).first

      # Don't copy object IDs as Mongo should generate new unique ones
      # Don't copy smart answers as we want users to use the latest version of the questions
      attributes = registration.attributes.except("_id",
                                                  "otherBusinesses",
                                                  "isMainService",
                                                  "constructionWaste",
                                                  "onlyAMF",
                                                  "addresses",
                                                  "key_people",
                                                  "financeDetails",
                                                  "declaredConvictions",
                                                  "conviction_search_result",
                                                  "conviction_sign_offs",
                                                  "declaration",
                                                  "past_registrations",
                                                  "copy_cards")

      assign_attributes(strip_whitespace(attributes))
      remove_invalid_attributes
    end

    def remove_invalid_attributes
      remove_invalid_phone_numbers
      remove_revoked_reason
    end

    def remove_invalid_phone_numbers
      validator = PhoneNumberValidator.new(attributes: :phone_number)
      return if validator.validate_each(self, :phone_number, phone_number)

      self.phone_number = nil
    end

    def remove_revoked_reason
      metaData.revoked_reason = nil
    end

    # Check if a transient renewal already exists for this registration so we don't have
    # multiple renewals in progress at once
    def no_renewal_in_progress?
      return unless TransientRegistration.where(reg_identifier: reg_identifier).exists?

      errors.add(:reg_identifier, :renewal_in_progress)
    end
  end
  # rubocop:enable Metrics/ClassLength
end
