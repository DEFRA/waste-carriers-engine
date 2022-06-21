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

      if @transient_registration.finance_details.orders.first.govpay_status == "success"
        Rails.logger.warn "Attempt to pay for an order with govpay_status already set to success"
        respond_to_acceptable_payment(:success)

      else
        @transient_registration.with_lock do
          payment_status = GovpayCallbackService.new(params[:uuid]).run

          case payment_status
          when :success, :pending
            respond_to_acceptable_payment(payment_status)
          else
            respond_to_unsuccessful_payment(payment_status)
          end
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

      if action != :error
        log_and_send_govpay_response(true, action)
        @transient_registration.next!
        redirect_to_correct_form
      else
        log_and_send_govpay_response(false, action)
        flash[:error] = I18n.t(".waste_carriers_engine.govpay_forms.#{action}.invalid_response")
        go_back
      end
    end

    def respond_to_unsuccessful_payment(action)
      return unless valid_transient_registration?

      if action != :error
        log_and_send_govpay_response(true, action)
        flash[:error] = I18n.t(".waste_carriers_engine.govpay_forms.#{action}.message")
      else
        log_and_send_govpay_response(false, action)
        flash[:error] = I18n.t(".waste_carriers_engine.govpay_forms.#{action}.invalid_response")
      end

      go_back
    end

    def valid_transient_registration?
      setup_checks_pass?
    end

    def log_and_send_govpay_response(is_valid, action)
      valid_text = is_valid ? "Valid" : "Invalid"
      title = "#{valid_text} Govpay response: #{action}"

      Rails.logger.debug [title, "Params:", params.to_json].join("\n")
      Airbrake.notify(title, error_message: params) unless is_valid && action == :success
    end
  end
end
