# frozen_string_literal: true

module WasteCarriersEngine
  class NewRegistration < TransientRegistration
    include CanUseNewRegistrationWorkflow
    include CanUseLock

    field :temp_start_option, type: String

    def prepare_for_payment(*_args)
      # TODO
    end

    private

    def registration_type_base_charges
      [Rails.configuration.new_registration_charge]
    end
  end
end
