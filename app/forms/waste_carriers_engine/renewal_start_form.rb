# frozen_string_literal: true

module WasteCarriersEngine
  class RenewalStartForm < BaseForm

    def initialize(transient_registration)
      super
    end

    def submit(params)
      attributes = {}

      super(attributes, params[:reg_identifier])
    end
  end
end
