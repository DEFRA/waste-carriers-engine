module WasteCarriersEngine
  class RegistrationPresenter < BasePresenter

    LOCALES_KEY = ".waste_carriers_engine.certificates.registration_pdf"

    def complex_organisation_details?
      return false unless ["soleTrader", "partnership"].include?(business_type)
      true
    end

    def carrier_name
      return company_name unless business_type == "soleTrader"

      # Based on the logic found in the existing certificate, we simply display
      # the company name field unless its a sole trader, in which case we take
      # the details entered into key people. For sole traders there will only be
      # one, but the list_main_people method still works for finding and
      # formatting the result found
      list_main_people
    end

    def tier_and_registration_type
      I18n.t("#{LOCALES_KEY}.registered_as",
        registration_type: I18n.t("#{LOCALES_KEY}.#{registrationType}")
      )
    end

    def expires_after_pluralized
      ActionController::Base.helpers.pluralize(
        Rails.configuration.expires_after,
        I18n.t("#{LOCALES_KEY}.year")
      )
    end

    def list_main_people
      list = key_people
        .select { |person| person.person_type == 'KEY' }
        .map    { |person| format('%s %s', person.first_name, person.last_name) }
      list.join("<br>").html_safe
    end

    def complex_organisation_title
      return I18n.t("#{LOCALES_KEY}.partners") if business_type == "partnership"
      I18n.t("#{LOCALES_KEY}.business_name_if_applicable")
    end

    def complex_organisation_name
      return company_name unless business_type == "partnership"

      # Based on the logic found in the existing certificate, we simply display
      # the company name field unless its a partnership, in which case we list
      # out all the partners
      list_main_people
    end

    def assisted_digital?
      metaData.route == "ASSISTED_DIGITAL"
    end
  end
end
