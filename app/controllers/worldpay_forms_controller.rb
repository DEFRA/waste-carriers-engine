class WorldpayFormsController < FormsController
  def new
    super(WorldpayForm, "worldpay_form")

    payment_info = prepare_for_payment
    if payment_info == :error
      flash[:error] = I18n.t(".worldpay_forms.new.setup_error")
      go_back
    else
      redirect_to payment_info[:url]
    end
  end

  def create; end

  def success
    return unless set_up_valid_transient_registration?(params[:reg_identifier])

    order_key = get_order_key(params[:orderKey])

    if order_key && valid_worldpay_success_response?(params, order_key)
      update_saved_data(order_key, params)
      @transient_registration.next!
      redirect_to_correct_form
    else
      flash[:error] = I18n.t(".worldpay_forms.success.invalid_response")
      go_back
    end
  end

  def failure
    return unless set_up_valid_transient_registration?(params[:reg_identifier])

    order_key = get_order_key(params[:orderKey])

    if order_key && valid_worldpay_failure_response?(params, order_key)
      order = @transient_registration.finance_details.orders.first
      order.update_after_worldpay(params[:paymentStatus])
      flash[:error] = I18n.t(".worldpay_forms.failure.message.#{params[:paymentStatus]}")
    else
      flash[:error] = I18n.t(".worldpay_forms.failure.invalid_response")
    end

    go_back
  end

  private

  def prepare_for_payment
    FinanceDetails.new_finance_details(@transient_registration)
    order = @transient_registration.finance_details.orders.first
    worldpay_service = WorldpayService.new(@transient_registration, order)
    worldpay_service.prepare_for_payment
  end

  def set_up_valid_transient_registration?(reg_identifier)
    set_transient_registration(reg_identifier)
    setup_checks_pass?
  end

  def get_order_key(order_key)
    return nil unless order_key
    order_key.match(/[0-9]{10}$/).to_s
  end

  def update_saved_data(order_key, params)
    order = @transient_registration.finance_details.orders.where(order_code: order_key).first
    payment = Payment.new_from_worldpay(order)
    payment.update_after_worldpay(params)
    order.update_after_worldpay(params[:paymentStatus])
    @transient_registration.finance_details.update_balance
  end

  def find_order(order_key)
    @transient_registration.finance_details.orders.where(order_code: order_key).first
  end

  # Validating WorldPay responses

  def valid_worldpay_success_response?(params, order_key)
    order = find_order(order_key)

    if order.present?
      valid_params?(params, order_key, order) && valid_success_payment_status?(params[:paymentStatus])
    else
      Rails.logger.error "Invalid WorldPay success response: could not find matching order"
      false
    end
  end

  def valid_worldpay_failure_response?(params, order_key)
    order = find_order(order_key)

    if order.present?
      valid_params?(params, order_key, order) && valid_failure_payment_status?(params[:paymentStatus])
    else
      Rails.logger.error "Invalid WorldPay failure response: could not find matching order"
      false
    end
  end

  def valid_params?(params, order_key, order)
    valid_mac?(params) &&
      valid_order_key_format?(params[:orderKey], order_key) &&
      valid_payment_amount?(params[:paymentAmount], order) &&
      valid_currency?(params[:paymentCurrency], order) &&
      valid_source?(params[:source])
  end

  # For the most up-to-date guidance about validating the MAC, see:
  # http://support.worldpay.com/support/kb/gg/corporate-gateway-guide/content/hostedintegration/securingpayments.htm
  # We have an older implementation with some differences (for example, params aren't separated by colons).
  def valid_mac?(params)
    data = [params[:orderKey],
            params[:paymentAmount],
            params[:paymentCurrency],
            params[:paymentStatus],
            Rails.configuration.worldpay_macsecret].join
    generated_mac = Digest::MD5.hexdigest(data).to_s
    return true if generated_mac == params[:mac]

    Rails.logger.error "Invalid WorldPay response: MAC is invalid"
    false
  end

  def valid_order_key_format?(param_order_key, order_key)
    valid_order_key = [Rails.configuration.worldpay_admin_code,
                       Rails.configuration.worldpay_merchantcode,
                       order_key].join("^")
    return true if param_order_key == valid_order_key

    Rails.logger.error "Invalid WorldPay response: order key #{param_order_key} is not valid format"
    false
  end

  def valid_success_payment_status?(status)
    return true if status == "AUTHORISED"

    Rails.logger.error "Invalid WorldPay response: #{status} is not valid payment status for success"
    false
  end

  def valid_failure_payment_status?(status)
    statuses = %w[CANCELLED
                  ERROR
                  EXPIRED
                  REFUSED]
    return true if statuses.include?(status)

    Rails.logger.error "Invalid WorldPay response: #{status} is not valid payment status for failure"
    false
  end

  def valid_payment_amount?(payment_amount, order)
    return true if payment_amount.to_i == order.total_amount

    Rails.logger.error "Invalid WorldPay response: #{payment_amount} is not valid payment amount"
    false
  end

  def valid_currency?(currency, order)
    return true if currency == order.currency

    Rails.logger.error "Invalid WorldPay response: #{currency} is not valid currency"
    false
  end

  def valid_source?(source)
    return true if source == "WP"

    Rails.logger.error "Invalid WorldPay response: #{source} is not valid source"
    false
  end
end
