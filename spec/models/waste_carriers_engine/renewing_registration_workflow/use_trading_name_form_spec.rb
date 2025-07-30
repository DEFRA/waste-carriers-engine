# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe RenewingRegistration do
    it_behaves_like "use_trading_name_form workflow", factory: :renewing_registration
  end
end
