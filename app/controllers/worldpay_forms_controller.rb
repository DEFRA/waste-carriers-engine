class WorldpayFormsController < FormsController
  def new
    super(WorldpayForm, "worldpay_form")

    worldpay_url = set_up_worldpay_url
    if worldpay_url == :error
      flash[:error] = "Error setting up WorldPay"
      go_back
    else
      redirect_to worldpay_url
    end
  end

  def create; end

  def success
    return unless set_up_form(WorldpayForm, "worldpay_form", params[:reg_identifier])

    @transient_registration.next!
    redirect_to_correct_form
  end

  def failure
    flash[:error] = "Payment failure"
    go_back
  end

  private

  def set_up_worldpay_url
    FinanceDetails.new_finance_details(@transient_registration)
    order = @transient_registration.finance_details.orders.first
    worldpay_service = WorldpayService.new(@transient_registration, order)
    worldpay_service.set_up_payment_link
  end
end
