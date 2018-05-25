class WorldpayService
  def initialize(transient_registration, order)
    @transient_registration = transient_registration
    @order = order
    @url = "https://secure-test.worldpay.com/jsp/merchant/xml/paymentService.jsp"
    @username = Rails.configuration.worldpay_username
    @password = Rails.configuration.worldpay_password
  end

  def set_up_payment_link
    response = send_request
    reference = parse_response(response)
    return :error unless reference.present?
    reference[:link]
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
end
