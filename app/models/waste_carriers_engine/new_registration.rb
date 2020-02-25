# frozen_string_literal: true

module WasteCarriersEngine
  class NewRegistration < TransientRegistration
    include CanUseNewRegistrationWorkflow
  end
end
