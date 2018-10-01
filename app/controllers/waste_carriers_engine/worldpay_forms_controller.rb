module WasteCarriersEngine
  class WorldpayFormsController < FormsController
    def new
      super(WorldpayForm, "worldpay_form")

      payment_info = prepare_for_payment
      if payment_info == :error
        flash[:error] = I18n.t(".waste_carriers_engine.worldpay_forms.new.setup_error")
        go_back
      else
        redirect_to payment_info[:url]
      end
    end

    def create; end

    def success
      return unless set_up_valid_transient_registration?(params[:reg_identifier])

      order = find_order_by_code(params[:orderKey])

      if valid_worldpay_success_response?(params, order)
        @transient_registration.next!
        redirect_to_correct_form
      else
        flash[:error] = I18n.t(".waste_carriers_engine.worldpay_forms.success.invalid_response")
        go_back
      end
    end

    def failure
      return unless set_up_valid_transient_registration?(params[:reg_identifier])

      order = find_order_by_code(params[:orderKey])

      if valid_worldpay_failure_response?(params, order)
        flash[:error] = I18n.t(".waste_carriers_engine.worldpay_forms.failure.message.#{params[:paymentStatus]}")
      else
        flash[:error] = I18n.t(".waste_carriers_engine.worldpay_forms.failure.invalid_response")
      end

      go_back
    end

    def cancel
      return unless set_up_valid_transient_registration?(params[:reg_identifier])

      order = find_order_by_code(params[:orderKey])

      if valid_worldpay_cancel_response?(params, order)
        flash[:error] = I18n.t(".waste_carriers_engine.worldpay_forms.failure.message.#{params[:paymentStatus]}")
      else
        flash[:error] = I18n.t(".waste_carriers_engine.worldpay_forms.failure.invalid_response")
      end

      go_back
    end

    def error
      return unless set_up_valid_transient_registration?(params[:reg_identifier])

      order = find_order_by_code(params[:orderKey])

      if valid_worldpay_error_response?(params, order)
        flash[:error] = I18n.t(".waste_carriers_engine.worldpay_forms.failure.message.#{params[:paymentStatus]}")
      else
        flash[:error] = I18n.t(".waste_carriers_engine.worldpay_forms.failure.invalid_response")
      end

      go_back
    end

    def pending
      return unless set_up_valid_transient_registration?(params[:reg_identifier])

      order = find_order_by_code(params[:orderKey])

      if valid_worldpay_pending_response?(params, order)
        flash[:error] = I18n.t(".waste_carriers_engine.worldpay_forms.failure.message.#{params[:paymentStatus]}")
      else
        flash[:error] = I18n.t(".waste_carriers_engine.worldpay_forms.failure.invalid_response")
      end

      go_back
    end

    private

    def prepare_for_payment
      FinanceDetails.new_finance_details(@transient_registration, :worldpay, current_user)
      order = @transient_registration.finance_details.orders.first
      worldpay_service = WorldpayService.new(@transient_registration, order, current_user)
      worldpay_service.prepare_for_payment
    end

    def set_up_valid_transient_registration?(reg_identifier)
      set_transient_registration(reg_identifier)
      setup_checks_pass?
    end

    def find_order_by_code(full_order_key)
      order_code = get_order_key(full_order_key)
      order = @transient_registration.finance_details.orders.where(order_code: order_code).first
      return order if order.present?

      Rails.logger.error "Invalid WorldPay response: could not find matching order"
      nil
    end

    def get_order_key(order_key)
      return nil unless order_key.present?
      order_key.match(/[0-9]{10}$/).to_s
    end

    def valid_worldpay_success_response?(params, order)
      new_worldpay_service(params, order).valid_success?
    end

    def valid_worldpay_failure_response?(params, order)
      new_worldpay_service(params, order).valid_failure?
    end

    def valid_worldpay_cancel_response?(params, order)
      new_worldpay_service(params, order).valid_cancel?
    end

    def valid_worldpay_error_response?(params, order)
      new_worldpay_service(params, order).valid_error?
    end

    def valid_worldpay_pending_response?(params, order)
      new_worldpay_service(params, order).valid_pending?
    end

    def new_worldpay_service(params, order)
      WorldpayService.new(@transient_registration, order, current_user, params)
    end
  end
end
