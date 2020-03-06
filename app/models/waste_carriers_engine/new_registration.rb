# frozen_string_literal: true

module WasteCarriersEngine
  class NewRegistration < TransientRegistration
    include CanUseNewRegistrationWorkflow
    include CanUseLock

    field :temp_start_option, type: String
  end
end
