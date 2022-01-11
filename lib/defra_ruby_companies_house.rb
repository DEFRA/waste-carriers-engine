# frozen_string_literal: true

require "rest-client"

class DefraRubyCompaniesHouse
  def initialize(company_no)
    @company_no = company_no
    @company_url = "#{DefraRuby::Validators.configuration.companies_house_host}#{@company_no}"
    @api_key = DefraRuby::Validators.configuration.companies_house_api_key
  end

  def company
    JSON.parse(
      RestClient::Request.execute(
        method: :get,
        url: @company_url,
        user: @api_key,
        password: ""
      )
    ).deep_symbolize_keys
  rescue RestClient::ResourceNotFound
    :not_found
  end
end
