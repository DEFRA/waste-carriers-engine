# frozen_string_literal: true

require "rest-client"

class DefraRubyCompaniesHouse
  def initialize(company_no)
    @company_url = "#{Rails.configuration.companies_house_host}#{company_no.to_s.rjust(8, '0')}"
    @api_key = Rails.configuration.companies_house_api_key

    raise StandardError "Failed to load company" unless load_company
  end

  def company_name
    @company[:company_name] if @company
  end

  def registered_office_address_lines
    return [] unless @company

    address = @company[:registered_office_address]

    [
      address[:address_line_1],
      address[:address_line_2],
      address[:locality],
      address[:postal_code]
    ].compact
  end

  private

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
    false
  end
end
