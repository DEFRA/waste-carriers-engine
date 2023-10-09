# frozen_string_literal: true

module WasteCarriersEngine
  class CertificatePresenter < BasePresenter
    include WasteCarriersEngine::ApplicationHelper

    LOCALES_KEY = ".waste_carriers_engine.pdfs.certificate"

    # If it's an upper tier sole trader or partnership, we need to display an
    # extra section. For partners, it's a list of their names, and for sole
    # traders, it's their business name.
    def complex_organisation_details?
      upper_tier_sole_trader? || upper_tier_partnership?
    end

    # The certificate displays headings on the left, and values from the
    # registration on the right. Because this heading is dynamic based on the
    # business type, we have a method for it in the presenter.
    def complex_organisation_heading
      if upper_tier_partnership?
        I18n.t("#{LOCALES_KEY}.partners")
      else
        I18n.t("#{LOCALES_KEY}.business_name_if_applicable")
      end
    end

    def complex_organisation_name
      if upper_tier_partnership?
        list_main_people
      else
        company_name
      end
    end

    def tier_and_registration_type
      if lower_tier?
        I18n.t("#{LOCALES_KEY}.registered_as.lower")
      else
        I18n.t("#{LOCALES_KEY}.registered_as.upper.",
               registration_type: I18n.t("#{LOCALES_KEY}.#{registration_type}"))
      end
    end

    def renewal_message
      if lower_tier?
        I18n.t("#{LOCALES_KEY}.lower_renewal")
      else
        I18n.t("#{LOCALES_KEY}.upper_renewal", expires_after_pluralized: expires_after_pluralized)
      end
    end

    def assisted_digital?
      metaData.route == "ASSISTED_DIGITAL"
    end

    def registered_address_fields
      displayable_address(registered_address)
    end

    def certificate_creation_date
      Date.today.to_s(:standard)
    end

    def certificate_version
      return 0 if metaData.certificate_version.nil?

      metaData.certificate_version
    end

    private

    def expires_after_pluralized
      ActionController::Base.helpers.pluralize(
        Rails.configuration.expires_after,
        I18n.t("#{LOCALES_KEY}.year")
      )
    end

    def list_main_people
      list = main_people.map do |person|
        format("%<first>s %<last>s", first: person.first_name, last: person.last_name)
      end
      list.join("<br>").html_safe
    end

    def upper_tier_sole_trader?
      upper_tier? && business_type == "soleTrader"
    end

    def upper_tier_partnership?
      upper_tier? && business_type == "partnership"
    end
  end
end
