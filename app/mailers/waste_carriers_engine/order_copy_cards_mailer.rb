# frozen_string_literal: true

module WasteCarriersEngine
  class OrderCopyCardsMailer < BaseMailer
    def send_order_completed_email(registration, order)
      @presenter = OrderCopyCardsMailerPresenter.new(registration, order)

      subject = I18n.t(
        ".waste_carriers_engine.order_copy_cards_mailer.send_order_completed_email.subject",
        count: @presenter.total_cards
      )

      mail(to: @presenter.contact_email,
           from: from_email,
           subject: subject)
    end

    def send_awaiting_payment_email(registration, order)
      @presenter = OrderCopyCardsMailerPresenter.new(registration, order)

      mail(to: @presenter.contact_email,
           from: from_email,
           subject: I18n.t(".waste_carriers_engine.order_copy_cards_mailer.send_awaiting_payment_email.subject"))
    end
  end
end
