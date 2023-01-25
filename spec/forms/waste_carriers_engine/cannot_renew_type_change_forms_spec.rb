# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe CannotRenewTypeChangeForm do
    describe "#workflow_state" do
      it_behaves_like "a fixed final state",
                      current_state: :cannot_renew_type_change_form,
                      factory: :renewing_registration
    end
  end
end
