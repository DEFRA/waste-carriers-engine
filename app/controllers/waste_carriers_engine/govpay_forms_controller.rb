# frozen_string_literal: true

module WasteCarriersEngine
  class GovpayFormsController < ::WasteCarriersEngine::FormsController
    include UnsubmittableForm
    include CanAddDebugLogging

    def new
      super(GovpayForm, "govpay_form")

      payment_info = prepare_for_payment

      if payment_info == :error
        flash[:error] = I18n.t(".waste_carriers_engine.govpay_forms.new.setup_error")
        go_back
      else
        redirect_to payment_info[:url], allow_other_host: true
      end
    end

    def payment_callback
      find_or_initialize_transient_registration(params[:token])

      govpay_payment_status = GovpayPaymentDetailsService.new(
        payment_uuid: params[:uuid],
        is_moto: WasteCarriersEngine.configuration.host_is_back_office?
      ).govpay_payment_status

      @transient_registration.with_lock do
        case GovpayPaymentDetailsService.payment_status(govpay_payment_status)
        when :success, :pending
          respond_to_acceptable_payment(govpay_payment_status)
        else
          respond_to_unsuccessful_payment(govpay_payment_status)
        end
      end
    rescue StandardError => e
      log_transient_registration_details("Error in payment callback", e, @transient_registration)
      Rails.logger.warn "Govpay payment callback error for payment uuid \"#{params[:uuid]}\": #{e}"
      Airbrake.notify(e, message: "Govpay callback error for payment uuid", payment_uuid: params[:uuid])
      flash[:error] = I18n.t(".waste_carriers_engine.govpay_forms.error")
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

      govpay_callback_service = create_govpay_callback_service(action)

      if govpay_callback_service.process_payment
        log_and_send_govpay_response(true, action)
        @transient_registration.next!
        redirect_to_correct_form
      else
        handle_invalid_response(action)
      end
    end

    def respond_to_unsuccessful_payment(action)
      return unless valid_transient_registration?

      govpay_callback_service = create_govpay_callback_service(action)

      if govpay_callback_service.process_payment
        log_and_send_govpay_response(true, action)
        form_error_message(action)
        go_back
      else
        handle_invalid_response(action)
      end
    end

    def create_govpay_callback_service(action)
      GovpayCallbackService.new(params[:uuid], action)
    end

    def handle_invalid_response(action)
      log_and_send_govpay_response(false, action)
      form_error_message(action, :invalid_response)
      go_back
    end

    def valid_transient_registration?
      setup_checks_pass?
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
