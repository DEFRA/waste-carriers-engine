# frozen_string_literal: true

require "rest-client"

class DefraRubyCompaniesHouse
  def initialize(company_no)
    @company_url = "#{Rails.configuration.companies_house_host}#{format_company_number(company_no)}"
    @api_key = Rails.configuration.companies_house_api_key
  end

  def company_name
    load_company unless @company

    @company[:company_name]
  end

  def registered_office_address_lines
    load_company unless @company

    address = @company[:registered_office_address]

    [
      address[:address_line_1],
      address[:address_line_2],
      address[:locality],
      address[:postal_code]
    ].compact
  end

  def company_status
    load_company unless @company

    @company[:company_status]
  end

  private

  def format_company_number(company_number)
    company_number&.to_s&.upcase&.rjust(8, "0")
  end

  def load_company
    @company =
      JSON.parse(
        RestClient::Request.execute(
          method: :get,
          url: @company_url,
          user: @api_key,
          password: ""
        )
      ).deep_symbolize_keys
  rescue RestClient::ResourceNotFound, RestClient::NotFound
    raise StandardError, "Failed to load company"
  end
end
