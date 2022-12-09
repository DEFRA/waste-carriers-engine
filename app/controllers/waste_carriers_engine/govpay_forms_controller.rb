# frozen_string_literal: true

module WasteCarriersEngine
  class GovpayFormsController < ::WasteCarriersEngine::FormsController
    include UnsubmittableForm

    def new
      super(GovpayForm, "govpay_form")

      payment_info = prepare_for_payment

      if payment_info == :error
        flash[:error] = I18n.t(".waste_carriers_engine.govpay_forms.new.setup_error")
        go_back
      else
        redirect_to payment_info[:url]
      end
    end

    def payment_callback
      find_or_initialize_transient_registration(params[:token])

      govpay_payment_status = GovpayPaymentDetailsService.new(payment_uuid: params[:uuid]).govpay_payment_status

      @transient_registration.with_lock do
        case GovpayPaymentDetailsService.payment_status(govpay_payment_status)
        when :success, :pending
          respond_to_acceptable_payment(govpay_payment_status)
        else
          respond_to_unsuccessful_payment(govpay_payment_status)
        end
      end
    rescue ArgumentError
      Rails.logger.warn "Govpay payment callback error: invalid payment uuid \"#{params[:uuid]}\""
      Airbrake.notify("Govpay callback error", "Invalid payment uuid \"#{params[:uuid]}\"")
      flash[:error] = I18n.t(".waste_carriers_engine.govpay_forms.new.internal_error")
      go_back
    end

    private

    def prepare_for_payment
      @transient_registration.prepare_for_payment(:govpay, current_user)
      order = @transient_registration.finance_details.orders.first
      govpay_service = GovpayPaymentService.new(@transient_registration, order, current_user)
      govpay_service.prepare_for_payment
    end

    def respond_to_acceptable_payment(action)
      return unless valid_transient_registration?

      if response_is_valid?(action, params)
        log_and_send_govpay_response(true, action)
        @transient_registration.next!
        redirect_to_correct_form
      else
        log_and_send_govpay_response(false, action)
        form_error_message(action, :invalid_response)
        go_back
      end
    end

    def respond_to_unsuccessful_payment(action)
      return unless valid_transient_registration?

      if response_is_valid?(action, params)
        log_and_send_govpay_response(true, action)
        form_error_message(action)
      else
        log_and_send_govpay_response(false, action)
        form_error_message(action, :invalid_response)
      end

      go_back
    end

    def valid_transient_registration?
      setup_checks_pass?
    end

    def response_is_valid?(action, params)
      valid_method = "valid_#{GovpayPaymentDetailsService.payment_status(action)}?".to_sym
      payment_uuid = params[:uuid]
      govpay_service = GovpayCallbackService.new(payment_uuid)

      govpay_service.public_send(valid_method)
    end

    def log_and_send_govpay_response(is_valid, action)
      return if is_valid && action != "error"

      valid_text = is_valid ? "Valid" : "Invalid"
      title = "#{valid_text} Govpay response: #{action}"
      Rails.logger.debug [title, "Params:", params.to_json].join("\n")
      Airbrake.notify(title, error_message: params)
    end

    def form_error_message(action, type = :message)
      action = GovpayPaymentDetailsService.payment_status(action)
      flash[:error] = I18n.t(".waste_carriers_engine.govpay_forms.#{action}.#{type}")
    end
  end
end
