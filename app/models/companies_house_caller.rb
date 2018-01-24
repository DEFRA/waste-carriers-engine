class CompaniesHouseCaller
  attr_accessor :company_no, :url, :api_key

  def initialize(company_no)
    self.company_no = process_company_no(company_no)
    self.url = "https://api.companieshouse.gov.uk/company/#{self.company_no}"
    self.api_key = Rails.configuration.companies_house_api_key
  end

  def call
    puts "Sending request to Companies House"
    begin
      response = RestClient::Request.execute(
        method: :get,
        url: url,
        user: api_key,
        password: ""
      )
      # TODO: Deal with what the request returns
      json = JSON.parse(response)
      puts json
      puts status_is_allowed?(json["company_status"])
    rescue RestClient::ExceptionWithResponse => e
      puts e.response
      # TODO: Deal with errors
    end
  end

  private

  def status_is_allowed?(status)
    %w[active].include?(status)
  end

  def process_company_no(company_no)
    number = company_no.to_s
    # Should be 8 characters, so if it's not, add 0s to the start
    number = "0#{number}" while number.length < 8
    number
  end
end
