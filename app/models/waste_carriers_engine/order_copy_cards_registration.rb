# frozen_string_literal: true

module WasteCarriersEngine
  class OrderCopyCardsRegistration < TransientRegistration
    include CanUseOrderCopyCardsWorkflow
    include CanUseLock

    validates :reg_identifier, "waste_carriers_engine/reg_identifier": true

    delegate :contact_address, :contact_email, :registered_address, to: :registration

    def registration
      @_registration ||= Registration.find_by(reg_identifier: reg_identifier)
    end

    def prepare_for_payment(mode, user)
      OrderAdditionalCardsService.run(
        cards_count: temp_cards,
        user: user,
        transient_registration: self,
        payment_method: mode
      )
    end
  end
end
