# frozen_string_literal: true

WasteCarriersEngine.configure do |config|
  # Companies House API config
  config.companies_house_host = ENV["WCRS_COMPANIES_HOUSE_URL"] || "https://api.companieshouse.gov.uk/company/"
  config.companies_house_api_key = ENV["WCRS_COMPANIES_HOUSE_API_KEY"]
end
