# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe NewRegistration do
    include_examples "company_address_manual_form workflow", factory: :new_registration
  end
end
