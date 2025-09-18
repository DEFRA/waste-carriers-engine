# frozen_string_literal: true

module WasteCarriersEngine
  class RegistrationNumberForm < ::WasteCarriersEngine::BaseForm
    delegate :company_no, :business_type, to: :transient_registration

    validates :company_no, "defra_ruby/validators/companies_house_number": {
      messages: custom_error_messages(:company_no, :inactive)
    }

    def submit(params)
      # Assign the params for validation and pass them to the BaseForm method for updating
      # If param isn't set, use a blank string instead to avoid errors with the validator
      params[:company_no] = format_company_no(params[:company_no])

      super
    end

    private

    def format_company_no(company_no)
      return "" if company_no.blank?

      company_no.to_s.upcase.rjust(8, "0")
    end
  end
end
