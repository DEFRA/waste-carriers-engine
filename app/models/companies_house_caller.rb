class CompaniesHouseCaller
  attr_accessor :company_no, :url, :api_key

  def initialize(company_no)
    self.company_no = process_company_no(company_no)
    self.url = "https://api.companieshouse.gov.uk/company/#{self.company_no}"
    self.api_key = Rails.configuration.companies_house_api_key
  end

  def call
    Rails.logger.debug "Sending request to Companies House"

    begin
      response = RestClient::Request.execute(
        method: :get,
        url: url,
        user: api_key,
        password: ""
      )

      json = JSON.parse(response)

      status_is_allowed?(json["company_status"]) ? :active : :inactive
    rescue RestClient::ResourceNotFound
      Rails.logger.debug "Companies House: resource not found"
      :not_found
    rescue RestClient::ExceptionWithResponse => e
      Rails.logger.error "Companies House error: " + e.to_s
      :error
    end
  end

  private

  def status_is_allowed?(status)
    %w[active voluntary-arrangement].include?(status)
  end

  def process_company_no(company_no)
    number = company_no.to_s
    # Should be 8 characters, so if it's not, add 0s to the start
    number = "0#{number}" while number.length < 8
    number
  end
end
