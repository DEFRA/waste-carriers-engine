# frozen_string_literal: true

module WasteCarriersEngine
  class PaymentSummaryForm < ::WasteCarriersEngine::BaseForm

    attr_accessor :temp_payment_method,
                  :registration_cards,
                  :registration_card_charge,
                  :total_charge,
                  :card_confirmation_email

    validates :temp_payment_method, inclusion: { in: %w[card bank_transfer] }
    validates :card_confirmation_email, "defra_ruby/validators/email": true, unless: :ignore_card_confirmation_email?

    def self.can_navigate_flexibly?
      false
    end

    def initialize(transient_registration)
      super

      self.temp_payment_method = transient_registration.temp_payment_method
      self.registration_cards = transient_registration.temp_cards || 0
      self.registration_card_charge = transient_registration.total_registration_card_charge
      self.total_charge = transient_registration.total_to_pay

      pre_populate_card_confirmation_email
    end

    def submit(params)
      # Update our attributes. Needed for validation to work as expected
      assign_params(params)

      # We always want to save the selected payment method in case the user
      # comes back to the form
      attributes = {
        temp_payment_method: temp_payment_method
      }

      # We only want to save the email address if the user is paying by card
      # and we are in the front-office
      attributes[:receipt_email] = card_confirmation_email unless ignore_card_confirmation_email?

      super(attributes)
    end

    private

    def pre_populate_card_confirmation_email
      return if WasteCarriersEngine.configuration.host_is_back_office?

      self.card_confirmation_email = transient_registration.email_to_send_receipt
    end

    def assign_params(params)
      self.temp_payment_method = params[:temp_payment_method]
      self.card_confirmation_email = params[:card_confirmation_email]
    end

    def ignore_card_confirmation_email?
      return true if WasteCarriersEngine::FeatureToggle.active?(:govpay_payments)

      return true if WasteCarriersEngine.configuration.host_is_back_office?

      temp_payment_method != "card"
    end
  end
end
