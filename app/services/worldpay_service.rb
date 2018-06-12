class WorldpayService
  def initialize(transient_registration, order, params = nil)
    @transient_registration = transient_registration
    @order = order
    @url = "https://secure-test.worldpay.com/jsp/merchant/xml/paymentService.jsp"
    @username = Rails.configuration.worldpay_username
    @password = Rails.configuration.worldpay_password

    assign_params(params) if params.present?
  end

  def prepare_for_payment
    response = send_request
    reference = parse_response(response)

    if reference.present?
      {
        payment: new_payment_object(@order),
        url: format_link(reference[:link])
      }
    else
      :error
    end
  end

  def valid_success?
    return false unless valid_order? && valid_params? && valid_success_payment_status?

    update_saved_data
    true
  end

  def valid_failure?
    return false unless valid_order? && valid_params? && valid_failure_payment_status?

    @order.update_after_worldpay(@status)
    true
  end

  private

  def assign_params(params)
    @params = params
    @order_key = params[:orderKey]
    @amount = params[:paymentAmount]
    @currency = params[:paymentCurrency]
    @status = params[:paymentStatus]
    @source = params[:source]
    @mac = params[:mac]
  end

  def update_saved_data
    payment = Payment.new_from_worldpay(@order)
    payment.update_after_worldpay(@params)
    @order.update_after_worldpay(@status)

    @transient_registration.finance_details.update_balance
    @transient_registration.finance_details.save!
  end

  # Preparing for a payment

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

  # Validating WorldPay responses

  def valid_order?
    return true if @order.present?

    Rails.logger.error "Invalid WorldPay response: cannot find matching order for #{@order_key}"
    false
  end

  def valid_params?
    valid_mac? &&
      valid_order_key_format? &&
      valid_payment_amount? &&
      valid_currency? &&
      valid_source?
  end

  # For the most up-to-date guidance about validating the MAC, see:
  # http://support.worldpay.com/support/kb/gg/corporate-gateway-guide/content/hostedintegration/securingpayments.htm
  # We have an older implementation with some differences (for example, params aren't separated by colons).
  def valid_mac?
    data = [@order_key,
            @amount,
            @currency,
            @status,
            Rails.configuration.worldpay_macsecret].join
    generated_mac = Digest::MD5.hexdigest(data).to_s
    return true if generated_mac == @mac

    Rails.logger.error "Invalid WorldPay response: MAC is invalid"
    false
  end

  def valid_order_key_format?
    valid_order_key = [Rails.configuration.worldpay_admin_code,
                       Rails.configuration.worldpay_merchantcode,
                       @order.order_code].join("^")
    return true if @order_key == valid_order_key

    Rails.logger.error "Invalid WorldPay response: order key #{@order_key} is not valid format"
    false
  end

  def valid_payment_amount?
    return true if @amount.to_i == @order.total_amount

    Rails.logger.error "Invalid WorldPay response: #{@amount} is not valid payment amount"
    false
  end

  def valid_currency?
    return true if @currency == @order.currency

    Rails.logger.error "Invalid WorldPay response: #{@currency} is not valid currency"
    false
  end

  def valid_source?
    return true if @source == "WP"

    Rails.logger.error "Invalid WorldPay response: #{@source} is not valid source"
    false
  end

  def valid_success_payment_status?
    return true if @status == "AUTHORISED"

    Rails.logger.error "Invalid WorldPay response: #{@status} is not valid payment status for success"
    false
  end

  def valid_failure_payment_status?
    statuses = %w[CANCELLED
                  ERROR
                  EXPIRED
                  REFUSED]
    return true if statuses.include?(@status)

    Rails.logger.error "Invalid WorldPay response: #{@status} is not valid payment status for failure"
    false
  end
end
