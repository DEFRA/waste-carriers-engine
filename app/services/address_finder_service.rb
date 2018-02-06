class AddressFinderService
  def initialize(postcode)
    # Strip out non-alphanumeric characters
    @postcode = postcode.gsub(/[^a-z0-9]/i, "")
    @url = Rails.configuration.os_places_service_url + "/addresses.json?postcode=" + @postcode
  end

  def search_by_postcode
    Rails.logger.debug "Sending request to OS Places service"

    begin
      response = RestClient::Request.execute(
        method: :get,
        url: @url
      )

      json = JSON.parse(response)

      json.each { |address| puts address["partial"] }
    rescue RestClient::BadRequest
      Rails.logger.debug "OS Places: resource not found"
      :not_found
    rescue RestClient::ExceptionWithResponse => e
      Airbrake.notify(e)
      Rails.logger.error "Os Places error: " + e.to_s
      :error
    end
  end
end
