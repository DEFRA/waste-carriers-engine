require "rest-client"

module WasteCarriersEngine
  class EntityMatchingService
    def initialize(transient_registration)
      @transient_registration = transient_registration
    end

    def check_business_for_matches
      data = query_service(company_url)
      store_match_result(@transient_registration, data)
    end

    def check_people_for_matches
      @transient_registration.key_people.each do |person|
        url = person_url(person)
        data = query_service(url)
        store_match_result(person, data)
      end
    end

    private

    def query_service(url)
      Rails.logger.debug "Sending request to Entity Matching service"

      begin
        response = RestClient::Request.execute(method: :get, url: url)

        begin
          JSON.parse(response)
        rescue JSON::ParserError => e
          Airbrake.notify(e) if defined?(Airbrake)
          Rails.logger.error "Entity Matching JSON error: " + e.to_s
          unknown_result_data
        end
      rescue RestClient::ExceptionWithResponse => e
        Airbrake.notify(e) if defined?(Airbrake)
        Rails.logger.error "Entity Matching response error: " + e.to_s
        unknown_result_data
      rescue Errno::ECONNREFUSED => e
        Airbrake.notify(e) if defined?(Airbrake)
        Rails.logger.error "Entity Matching connection error: " + e.to_s
        unknown_result_data
      rescue SocketError => e
        Airbrake.notify(e) if defined?(Airbrake)
        Rails.logger.error "Entity Matching socket error: " + e.to_s
        unknown_result_data
      end
    end

    def store_match_result(entity, data)
      entity.conviction_search_result = ConvictionSearchResult.new_from_entity_matching_service(data)
      entity.save!
    end

    def unknown_result_data
      {
        "match_result" => "UNKNOWN",
        "matching_system" => "ERROR",
        "searched_at" => Time.now.to_i,
        "confirmed" => "no"
      }
    end

    # URLs

    def base_url
      "#{Rails.configuration.wcrs_services_url}/match/"
    end

    def company_url
      "#{base_url}company?name=#{@transient_registration.company_name}&number=#{@transient_registration.company_no}"
    end

    def person_url(person)
      first_name = person.first_name
      last_name = person.last_name
      date_of_birth = person.dob.to_s(:entity_matching)
      "#{base_url}person?firstname=#{first_name}&lastname=#{last_name}&dateofbirth=#{date_of_birth}"
    end
  end
end
