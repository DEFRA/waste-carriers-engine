# frozen_string_literal: true

module WasteCarriersEngine
  class CertificatePresenter < BasePresenter

    LOCALES_KEY = ".waste_carriers_engine.pdfs.certificate"

    def carrier_name
      return company_name unless business_type == "soleTrader"

      # Based on the logic found in the existing certificate, we simply display
      # the company name field unless its a sole trader, in which case we take
      # the details entered into key people. For sole traders there will only be
      # one, but the list_main_people method still works for finding and
      # formatting the result found
      list_main_people
    end

    # By complex we mean is there a need to display extra detail in the
    # document. If its a soletrader we display we display an extra section,
    # which in the case of partners is a list of their names, and for sole
    # traders its their business name.
    def complex_organisation_details?
      return false unless %w[soleTrader partnership].include?(business_type)

      true
    end

    # The certificate displays headings on the left, and values from the
    # registration on the right. Because this heading is dynamic based on the
    # business type, we have a method for it in the presenter
    def complex_organisation_heading
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

    def tier_and_registration_type
      return I18n.t("#{LOCALES_KEY}.registered_as.lower") if lower_tier?

      I18n.t("#{LOCALES_KEY}.registered_as.upper.",
             registration_type: I18n.t("#{LOCALES_KEY}.#{registrationType}"))
    end

    def expires_after_pluralized
      ActionController::Base.helpers.pluralize(
        Rails.configuration.expires_after,
        I18n.t("#{LOCALES_KEY}.year")
      )
    end

    def list_main_people
      list = key_people
             .select { |person| person.person_type == "KEY" }
             .map    { |person| format("%<first>s %<last>s", first: person.first_name, last: person.last_name) }
      list.join("<br>").html_safe
    end

    def assisted_digital?
      metaData.route == "ASSISTED_DIGITAL"
    end
  end
end
