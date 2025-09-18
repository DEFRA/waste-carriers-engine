# frozen_string_literal: true

module WasteCarriersEngine
  class GovpayUpdateRefundStatusService < WasteCarriersEngine::BaseService
    attr_accessor :refund, :previous_status

    def run(refund:, new_status:)
      return false if refund.blank?

      @refund = refund

      return false if new_status != Payment::STATUS_SUCCESS

      @previous_status = refund.reload.govpay_payment_status

      return false if new_status == previous_status

      process_success

      true
    rescue StandardError => e
      payment = WasteCarriersEngine::GovpayFindPaymentService.run(payment_id: refund.refunded_payment_govpay_id)
      payment_id = payment&.govpay_id
      refund_id = refund.govpay_id
      Rails.logger.error "#{e.class} error in Govpay update refund details service for payment " \
                         "#{payment_id}, refund #{refund_id}"
      Airbrake.notify(e, message: "Error in Govpay update refund details service", payment_id:, refund_id:)
      raise e
    end

    private

    def process_success
      refund.update(
        {
          govpay_payment_status: Payment::STATUS_SUCCESS,
          comment: I18n.t("refunds.comments.card_complete"),
          order_key: refund.order_key.sub("_PENDING", "_REFUNDED")
        }
      )
      refund.save!

      registration = GovpayFindRegistrationService.run(payment: refund)
      if registration.nil?
        raise StandardError, "Registration not found for refund for payment #{refund.refunded_payment_govpay_id}"
      end

      registration.reload.finance_details.update_balance
      registration.save!

      Rails.logger.info "Updated refund status from #{previous_status} to \"#{Payment::STATUS_SUCCESS}\" " \
                        "for refund #{refund.govpay_id}, registration #{registration&.regIdentifier}"
    end
  end
end
