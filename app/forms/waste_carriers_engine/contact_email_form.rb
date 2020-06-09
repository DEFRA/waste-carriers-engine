# frozen_string_literal: true

module WasteCarriersEngine
  class ContactEmailForm < BaseForm
    delegate :contact_email, to: :transient_registration
    attr_accessor :confirmed_email

    validates :contact_email, "defra_ruby/validators/email": true
    validates :confirmed_email, "waste_carriers_engine/matching_email": { compare_to: :contact_email }

    after_initialize :populate_confirmed_email

    def submit(params)
      # Assign the params for validation and pass them to the BaseForm method for updating
      self.confirmed_email = params[:confirmed_email]

      super(params.permit(:contact_email))
    end

    private

    def populate_confirmed_email
      self.confirmed_email = contact_email
    end
  end
end
