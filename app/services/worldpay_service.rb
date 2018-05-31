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
    format_link(reference[:link])
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

  def format_link(url)
    [url,
     success_url,
     pending_url,
     failure_url,
     cancel_url,
     error_url].join
  end

  def success_url
    ["&successURL=", success_path].join
  end

  def pending_url
    ["&pendingURL=", failure_path].join
  end

  def failure_url
    ["&failureURL=", failure_path].join
  end

  def cancel_url
    ["&cancelURL=", failure_path].join
  end

  def error_url
    ["&errorURL=", failure_path].join
  end

  def success_path
    url = [Rails.configuration.wcrs_renewals_url,
           Rails.application.routes.url_helpers.success_worldpay_forms_path(@transient_registration.reg_identifier)]
    CGI.escape(url.join)
  end

  def failure_path
    url = [Rails.configuration.wcrs_renewals_url,
           Rails.application.routes.url_helpers.failure_worldpay_forms_path(@transient_registration.reg_identifier)]
    CGI.escape(url.join)
  end
end
