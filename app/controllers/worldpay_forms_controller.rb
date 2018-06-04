class WorldpayFormsController < FormsController
  def new
    super(WorldpayForm, "worldpay_form")

    payment_info = prepare_for_payment
    if payment_info == :error
      flash[:error] = "Error setting up WorldPay"
      go_back
    else
      redirect_to payment_info[:url]
    end
  end

  def create; end

  def success
    return unless set_up_form(WorldpayForm, "worldpay_form", params[:reg_identifier])

    if valid_worldpay_response?(params)
      @transient_registration.next!
      redirect_to_correct_form
    else
      flash[:error] = "Invalid response from WorldPay"
      go_back
    end
  end

  def failure
    flash[:error] = "Payment failure"
    go_back
  end

  private

  def prepare_for_payment
    FinanceDetails.new_finance_details(@transient_registration)
    order = @transient_registration.finance_details.orders.first
    worldpay_service = WorldpayService.new(@transient_registration, order)
    worldpay_service.prepare_for_payment
  end

  def valid_worldpay_response?(params)
    # Extract the 10 digits at the end of the order key param
    order_key = get_order_key(params[:orderKey])
    return false unless order_key.present?

    order = find_order(order_key)

    if order.present?
      valid_params?(params, order_key, order)
    else
      Rails.logger.error "Invalid WorldPay response: could not find matching order"
      false
    end
  end

  def valid_params?(params, order_key, order)
    valid_mac?(params[:mac]) &&
      valid_order_key_format?(params[:orderKey], order_key) &&
      valid_payment_status?(params[:paymentStatus]) &&
      valid_payment_amount?(params[:paymentAmount], order) &&
      valid_currency?(params[:paymentCurrency], order) &&
      valid_source?(params[:source])
  end

  def get_order_key(order_key)
    order_key.match(/[0-9]{10}$/)
  end

  def find_order(order_key)
    @transient_registration.finance_details.orders.where(order_code: order_key).first
  end

  # TODO
  def valid_mac?(_mac)
    true
  end

  def valid_order_key_format?(param_order_key, order_key)
    valid_order_key = [Rails.configuration.worldpay_admin_code,
                       Rails.configuration.worldpay_merchantcode,
                       order_key].join("^")
    return true if param_order_key == valid_order_key
    Rails.logger.error "Invalid WorldPay response: order key #{param_order_key} is not valid format"
    false
  end

  def valid_payment_status?(status)
    return true if status == "AUTHORISED"
    Rails.logger.error "Invalid WorldPay response: #{status} is not valid payment status for success"
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
