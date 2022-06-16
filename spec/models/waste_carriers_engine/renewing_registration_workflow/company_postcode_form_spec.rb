# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe RenewingRegistration do
    include_examples "company_postcode_form workflow", factory: :renewing_registration
  end
end
