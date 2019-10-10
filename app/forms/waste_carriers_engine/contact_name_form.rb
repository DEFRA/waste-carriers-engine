# frozen_string_literal: true

module WasteCarriersEngine
  class ContactNameForm < BaseForm
    delegate :first_name, :last_name, to: :transient_registration

    validates :first_name, :last_name, "waste_carriers_engine/person_name": true
  end
end
