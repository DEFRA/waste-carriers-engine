class EntityMatchingService
  def initialize(transient_registration)
    @transient_registration = transient_registration
  end

  def check_business_for_matches
    query_service(company_no_url) if @transient_registration.company_no.present?
    query_service(company_name_url)
  end

  def check_people_for_matches
    result = ""
    @transient_registration.keyPeople.each do |person|
      url = person_url(person)
      result = query_service(url)
    end
    # Temporarily return this so we have something to test
    result
  end

  private

  def query_service(url)
    Rails.logger.debug "Sending request to Entity Matching service"

    begin
      response = RestClient::Request.execute(method: :get, url: url)

      begin
        JSON.parse(response)
      rescue JSON::ParserError => e
        Airbrake.notify(e)
        Rails.logger.error "Entity Matching JSON error: " + e.to_s
        error_data
      end
    rescue RestClient::ExceptionWithResponse => e
      Airbrake.notify(e)
      Rails.logger.error "Entity Matching response error: " + e.to_s
      error_data
    rescue Errno::ECONNREFUSED => e
      Airbrake.notify(e)
      Rails.logger.error "Entity Matching connection error: " + e.to_s
      error_data
    rescue SocketError => e
      Airbrake.notify(e)
      Rails.logger.error "Entity Matching socket error: " + e.to_s
      error_data
    end
  end

  def error_data
    {
      match_result: "UNKNOWN",
      matching_system: "ERROR",
      searched_at: Time.now.to_i,
      confirmed: "no"
    }
  end

  # URLs

  def base_url
    "#{Rails.configuration.wcrs_services_url}/match/"
  end

  def company_name_url
    "#{base_url}company?name=#{@transient_registration.company_name}"
  end

  def company_no_url
    "#{base_url}company?number=#{@transient_registration.company_no}"
  end

  def person_url(person)
    first_name = person.first_name
    last_name = person.last_name
    date_of_birth = person.date_of_birth.to_s(:entity_matching)
    "#{base_url}person?firstname=#{first_name}&lastname=#{last_name}&dateofbirth=#{date_of_birth}"
  end
end
