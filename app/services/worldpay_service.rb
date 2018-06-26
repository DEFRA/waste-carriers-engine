class WorldpayService
  def initialize(transient_registration, order, params = nil)
    @transient_registration = transient_registration
    @order = order
    @url = Rails.configuration.worldpay_url
    @username = Rails.configuration.worldpay_username
    @password = Rails.configuration.worldpay_password
    @params = params
  end

  def prepare_for_payment
    response = send_request
    reference = parse_response(response)

    if reference.present?
      worldpay_url_service = WorldpayUrlService.new(@transient_registration.reg_identifier, reference[:link])
      url = worldpay_url_service.format_link

      {
        payment: new_payment_object(@order),
        url: url
      }
    else
      :error
    end
  end

  def valid_success?
    worldpay_validator_service = WorldpayValidatorService.new(@order, @params)
    return false unless worldpay_validator_service.valid_success?

    update_saved_data
    true
  end

  def valid_failure?
    worldpay_validator_service = WorldpayValidatorService.new(@order, @params)
    return false unless worldpay_validator_service.valid_failure?

    @order.update_after_worldpay(@params[:paymentStatus])
    true
  end

  private

  def send_request
    xml_service = WorldpayXmlService.new(@transient_registration, @order)
    xml = xml_service.build_xml

    Rails.logger.debug "Sending initial request to WorldPay"

    begin
      response = RestClient::Request.execute(
        method: :get,
        url: @url,
        payload: xml,
        headers: {
          "Authorization" => "Basic " + Base64.encode64(@username + ":" + @password).to_s
        }
      )

      Rails.logger.debug "Received response from WorldPay"
      response
    end
  end

  def parse_response(response)
    doc = Nokogiri::XML(response)
    reference = doc.at_xpath("//reference")

    if reference.present?
      reference_id = reference.attribute("id").text
      reference_link = reference.text

      { id: reference_id, link: reference_link }
    else
      Rails.logger.error "Could not parse Worldpay response: #{response}"
      return nil
    end
  end

  def new_payment_object(order)
    Payment.new_from_worldpay(order)
  end

  def update_saved_data
    payment = Payment.new_from_worldpay(@order)
    payment.update_after_worldpay(@params)
    @order.update_after_worldpay(@params[:paymentStatus])

    @transient_registration.finance_details.update_balance
    @transient_registration.finance_details.save!
  end
end
