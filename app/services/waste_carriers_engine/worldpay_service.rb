# frozen_string_literal: true

require "rest-client"

module WasteCarriersEngine
  class WorldpayService
    include CanSendWorldpayRequest

    def initialize(transient_registration, order, current_user, params = nil)
      @transient_registration = transient_registration
      @order = order
      @params = prepare_params(params)
      @current_user = current_user
    end

    def prepare_for_payment
      xml_service = WorldpayXmlService.new(@transient_registration, @order, @current_user)
      xml = xml_service.build_xml
      response = send_request(xml)
      reference = parse_response(response)

      if reference.present?
        worldpay_url_service = WorldpayUrlService.new(@transient_registration.token, reference[:link])
        url = worldpay_url_service.format_link

        {
          payment: new_payment_object(@order),
          url: url
        }
      else
        :error
      end
    end

    def valid_success?
      worldpay_validator_service = WorldpayValidatorService.new(@order, @params)
      return false unless worldpay_validator_service.valid_success?

      update_saved_data
      true
    end

    def valid_failure?
      valid_unsuccessful_payment?(:valid_failure?)
    end

    def valid_pending?
      valid_unsuccessful_payment?(:valid_pending?)
    end

    def valid_cancel?
      valid_unsuccessful_payment?(:valid_cancel?)
    end

    def valid_error?
      valid_unsuccessful_payment?(:valid_error?)
    end

    private

    def valid_unsuccessful_payment?(validation_method)
      worldpay_validator_service = WorldpayValidatorService.new(@order, @params)
      return false unless worldpay_validator_service.public_send(validation_method)

      @order.update_after_worldpay(@params[:paymentStatus])
      true
    end

    def prepare_params(params)
      return if params.nil?

      # Params can be different if the order is cancelled, so we need to reassign some of them
      params[:paymentAmount] = params[:orderAmount] if params[:paymentAmount].nil?
      params[:paymentCurrency] = params[:orderCurrency] if params[:paymentCurrency].nil?
      params[:paymentStatus] = "CANCELLED" if params[:paymentStatus].nil?

      params
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
        nil
      end
    end

    def new_payment_object(order)
      Payment.new_from_worldpay(order, @current_user)
    end

    def update_saved_data
      payment = Payment.new_from_worldpay(@order, @current_user)
      payment.update_after_worldpay(@params)
      @order.update_after_worldpay(@params[:paymentStatus])

      @transient_registration.finance_details.update_balance
      @transient_registration.finance_details.save!
    end
  end
end
