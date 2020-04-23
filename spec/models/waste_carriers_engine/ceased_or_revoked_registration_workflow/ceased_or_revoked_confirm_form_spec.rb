# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe CeasedOrRevokedRegistration do
    subject(:ceased_or_revoked_registration) { build(:ceased_or_revoked_registration, workflow_state: "ceased_or_revoked_confirm_form") }

    describe "#workflow_state" do
      context ":ceased_or_revoked_confirm_form state transitions" do
        context "on next" do
          include_examples "has next transition", next_state: "ceased_or_revoked_completed_form"
        end

        context "on back" do
          include_examples "has back transition", previous_state: "cease_or_revoke_form"
        end
      end
    end
  end
end
