# frozen_string_literal: true

module WasteCarriersEngine
  class ContactEmailForm < ::WasteCarriersEngine::BaseForm
    include CanStripWhitespace

    delegate :contact_email, to: :transient_registration
    attr_accessor :confirmed_email, :no_contact_email

    validates_with ContactEmailValidator, attributes: [:contact_email]

    def submit(params)
      # Strip whitespace here because confirmed_email does not get passed to the base form
      params = strip_whitespace(params)

      # Blank email address values should be processed as nil
      params[:contact_email] = nil if params[:contact_email].blank?
      params[:confirmed_email] = nil if params[:confirmed_email].blank?

      # Assign the params for validation and pass them to the BaseForm method for updating
      self.confirmed_email = params[:confirmed_email]
      self.no_contact_email = params[:no_contact_email]

      super(params.permit(:contact_email))
    end
  end
end
