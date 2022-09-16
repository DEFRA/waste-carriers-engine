# frozen_string_literal: true

module WasteCarriersEngine
  class ContactEmailForm < ::WasteCarriersEngine::BaseForm
    delegate :contact_email, to: :transient_registration
    attr_accessor :confirmed_email
    attr_accessor :no_contact_email

    validates_with ContactEmailValidator, attributes: [:contact_email]

    after_initialize :populate_confirmed_email

    def submit(params)
      # Blank email address vluaes should be processed as nil
      params[:contact_email] = nil if params[:contact_email].blank?
      params[:confirmed_email] = nil if params[:confirmed_email].blank?

      # Assign the params for validation and pass them to the BaseForm method for updating
      self.confirmed_email = params[:confirmed_email]
      self.no_contact_email = params[:no_contact_email]

      super(params.permit(:contact_email))
    end

    private

    def populate_confirmed_email
      self.confirmed_email = contact_email
    end
  end
end
