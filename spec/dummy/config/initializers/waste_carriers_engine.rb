# frozen_string_literal: true

WasteCarriersEngine.configure do |config|
  # Companies House API config
  config.companies_house_host = ENV["WCRS_COMPANIES_HOUSE_URL"] || "https://api.companieshouse.gov.uk/company/"
  config.companies_house_api_key = ENV["WCRS_COMPANIES_HOUSE_API_KEY"]

  # Airbrake config
  config.airbrake_enabled = false
  config.airbrake_host = "http://localhost"
  config.airbrake_project_key = "abcde12345"
  config.airbrake_blacklist = [/password/i, /authorization/i]
end
WasteCarriersEngine.start_airbrake
