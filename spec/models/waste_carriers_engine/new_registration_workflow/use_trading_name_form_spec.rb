# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe NewRegistration do
    it_behaves_like "use_trading_name_form workflow", factory: :new_registration
  end
end
