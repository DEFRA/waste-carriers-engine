# frozen_string_literal: true

module WasteCarriersEngine
  class IncorrectCompanyForm < ::WasteCarriersEngine::BaseForm
    include CannotSubmit
  end
end
