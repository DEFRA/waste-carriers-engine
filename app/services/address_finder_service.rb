class AddressFinderService
  def initialize(postcode)
    @postcode = postcode.delete(" ") || ""
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

      puts json
    rescue RestClient::BadRequest
      Rails.logger.debug "OS Places: resource not found"
      :not_found
    rescue RestClient::ExceptionWithResponse => e
      Rails.logger.error "Os Places error: " + e.to_s
      :error
    end
  end
end
