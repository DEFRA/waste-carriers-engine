# frozen_string_literal: true

module WasteCarriersEngine
  class OrderCopyCardsRegistration < TransientRegistration
    # due to issues with mongoid-locker v2.0.2, delegate has to be added to the top of the class
    delegate :contact_address, :contact_email, :registered_address, to: :registration

    include CanUseOrderCopyCardsWorkflow
    include CanUseLock

    validates :reg_identifier, "waste_carriers_engine/reg_identifier": true

    def registration
      @_registration ||= Registration.find_by(reg_identifier: reg_identifier)
    end

    def prepare_for_payment(mode, user)
      BuildOrderCopyCardsFinanceDetailsService.run(
        cards_count: temp_cards,
        user: user,
        transient_registration: self,
        payment_method: mode
      )
    end
  end
end
