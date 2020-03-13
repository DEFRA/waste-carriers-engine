# frozen_string_literal: true

module WasteCarriersEngine
  class NewRegistration < TransientRegistration
    include CanUseNewRegistrationWorkflow
    include CanUseLock

    field :temp_start_option, type: String

    def prepare_for_payment(*_args)
      # TODO
    end

    def reg_identifier
      return unless super.present?

      prefix = lower_tier? ? "CBDL" : "CBDU"

      prefix + super.to_s
    end

    private

    def registration_type_base_charges
      [Rails.configuration.new_registration_charge]
    end
  end
end
