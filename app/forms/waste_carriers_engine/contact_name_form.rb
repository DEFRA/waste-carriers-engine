# frozen_string_literal: true

module WasteCarriersEngine
  class ContactNameForm < BaseForm
    attr_accessor :first_name, :last_name

    validates :first_name, :last_name, "waste_carriers_engine/person_name": true

    def initialize(transient_registration)
      super

      self.first_name = transient_registration.first_name
      self.last_name = transient_registration.last_name
    end

    def submit(params)
      # Assign the params for validation and pass them to the BaseForm method for updating
      self.first_name = params[:first_name]
      self.last_name = params[:last_name]
      attributes = {
        first_name: first_name,
        last_name: last_name
      }

      super(attributes)
    end
  end
end
