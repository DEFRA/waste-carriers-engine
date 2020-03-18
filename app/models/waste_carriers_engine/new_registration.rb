# frozen_string_literal: true

module WasteCarriersEngine
  class NewRegistration < TransientRegistration
    include CanUseNewRegistrationWorkflow
    include CanUseLock

    field :temp_start_option, type: String

    after_initialize :build_meta_data

    def prepare_for_payment(mode, _user)
      BuildNewRegistrationFinanceDetailsService.run(
        transient_registration: self,
        payment_method: mode
      )
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

    def build_meta_data
      build_metaData unless metaData.present?
    end
  end
end
