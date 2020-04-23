# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe CeasedOrRevokedRegistration do
    subject(:ceased_or_revoked_registration) { build(:ceased_or_revoked_registration, workflow_state: "cease_or_revoke_form") }

    describe "#workflow_state" do
      context ":cease_or_revoke_form state transitions" do
        context "on next" do
          include_examples "has next transition", next_state: "ceased_or_revoked_confirm_form"
        end
      end
    end
  end
end
