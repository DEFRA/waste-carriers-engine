class CompaniesHouseService
  def initialize(company_no)
    @company_no = company_no
    @url = "https://api.companieshouse.gov.uk/company/#{@company_no}"
    @api_key = Rails.configuration.companies_house_api_key
  end

  def status
    Rails.logger.debug "Sending request to Companies House"

    begin
      response = RestClient::Request.execute(
        method: :get,
        url: @url,
        user: @api_key,
        password: ""
      )

      json = JSON.parse(response)

      status_is_allowed?(json["company_status"]) ? :active : :inactive
    rescue RestClient::ResourceNotFound
      Rails.logger.debug "Companies House: resource not found"
      :not_found
    rescue RestClient::ExceptionWithResponse => e
      Airbrake.notify(e)
      Rails.logger.error "Companies House error: " + e.to_s
      :error
    end
  end

  private

  def status_is_allowed?(status)
    %w[active voluntary-arrangement].include?(status)
  end
end
