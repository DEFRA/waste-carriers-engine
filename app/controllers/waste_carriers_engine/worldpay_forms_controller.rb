# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
module WasteCarriersEngine
  class WorldpayFormsController < ::WasteCarriersEngine::FormsController
    include UnsubmittableForm

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

    def success
      find_or_initialize_transient_registration(params[:token])

      @transient_registration.with_lock do
        respond_to_acceptable_payment(:success)
      end
    end

    def pending
      find_or_initialize_transient_registration(params[:token])

      @transient_registration.with_lock do
        respond_to_acceptable_payment(:pending)
      end
    end

    def failure
      find_or_initialize_transient_registration(params[:token])

      @transient_registration.with_lock do
        respond_to_unsuccessful_payment(:failure)
      end
    end

    def cancel
      find_or_initialize_transient_registration(params[:token])

      @transient_registration.with_lock do
        respond_to_unsuccessful_payment(:cancel)
      end
    end

    def error
      find_or_initialize_transient_registration(params[:token])

      @transient_registration.with_lock do
        respond_to_unsuccessful_payment(:error)
      end
    end

    private

    def prepare_for_payment
      @transient_registration.prepare_for_payment(:worldpay, current_user)
      order = @transient_registration.finance_details.orders.first
      worldpay_service = WorldpayService.new(@transient_registration, order, current_user)
      worldpay_service.prepare_for_payment
    end

    def respond_to_acceptable_payment(action)
      return unless valid_transient_registration?

      if response_is_valid?(action, params)
        log_and_send_worldpay_response(true, action)
        @transient_registration.next_state!
        redirect_to_correct_form
      else
        log_and_send_worldpay_response(false, action)
        flash[:error] = I18n.t(".waste_carriers_engine.worldpay_forms.#{action}.invalid_response")
        go_back
      end
    end

    def respond_to_unsuccessful_payment(action)
      return unless valid_transient_registration?

      if response_is_valid?(action, params)
        log_and_send_worldpay_response(true, action)
        flash[:error] = I18n.t(".waste_carriers_engine.worldpay_forms.#{action}.message")
      else
        log_and_send_worldpay_response(false, action)
        flash[:error] = I18n.t(".waste_carriers_engine.worldpay_forms.#{action}.invalid_response")
      end

      go_back
    end

    def valid_transient_registration?
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

    def response_is_valid?(action, params)
      valid_method = "valid_#{action}?".to_sym

      worldpay_service(params).public_send(valid_method)
    end

    def worldpay_service(params)
      order = find_order_by_code(params[:orderKey])
      WorldpayService.new(@transient_registration, order, current_user, params)
    end

    def log_and_send_worldpay_response(is_valid, action)
      valid_text = if is_valid
                     "Valid"
                   else
                     "Invalid"
                   end
      title = "#{valid_text} WorldPay response: #{action}"

      log_worldpay_response(title)
      send_worldpay_response_to_airbrake(title) unless is_valid && action == :success
    end

    def log_worldpay_response(title)
      message = [title, "Params:", params.to_json].join("\n")
      Rails.logger.debug message
    end

    def send_worldpay_response_to_airbrake(title)
      Airbrake.notify(title, error_message: params)
    end
  end
end
# rubocop:enable Metrics/ClassLength
