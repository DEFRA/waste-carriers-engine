# Validates requests to record a successful or failed Worldpay payment.

# This should happen after a user attempts to make a payment on the Worldpay site. They are then redirected to
# either a success or failure route, depending on the result. However, we need to make sure the params match
# what we expect Worldpay to send us before we record that a payment has been made (or failed) and allow the user
# to continue.
class WorldpayValidatorService
  def initialize(order, params)
    @order = order
    @params = params
    @order_key = params[:orderKey]
    @amount = params[:paymentAmount]
    @currency = params[:paymentCurrency]
    @status = params[:paymentStatus]
    @source = params[:source]
    @mac = params[:mac]
  end

  def valid_success?
    valid_order? && valid_params? && valid_success_payment_status?
  end

  def valid_failure?
    valid_order? && valid_params? && valid_failure_payment_status?
  end

  private

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
