# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe NewRegistration do
    it_behaves_like "a postcode transition",
                    address_type: "contact",
                    factory: :new_registration
  end
end
