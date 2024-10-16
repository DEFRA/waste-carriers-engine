# frozen_string_literal: true

module WasteCarriersEngine
  class ContactAddressAsRegisteredAddressService < BaseService
    def run(transient_registration)
      @transient_registration = transient_registration

      return unless @transient_registration.registered_address

      cloned_address = @transient_registration.registered_address.clone
      cloned_address.addressType = "POSTAL"

      @transient_registration.update(contact_address: cloned_address)
    end
  end
end
