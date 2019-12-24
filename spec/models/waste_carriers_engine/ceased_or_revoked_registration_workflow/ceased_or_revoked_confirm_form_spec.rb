# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe CeasedOrRevokedRegistration do
    subject(:ceased_or_revoked_registration) { build(:ceased_or_revoked_registration) }

    describe "#workflow_state" do
      context ":ceased_or_revoked_confirm_form state transitions" do
        context "on next" do
          it "can transition from a :ceased_or_revoked_confirm_form state to a :ceased_or_revoked_completed_form" do
            ceased_or_revoked_registration.workflow_state = :ceased_or_revoked_confirm_form

            ceased_or_revoked_registration.next

            expect(ceased_or_revoked_registration.workflow_state).to eq("ceased_or_revoked_completed_form")
          end
        end

        context "on back" do
          it "can transition from a :ceased_or_revoked_confirm_form state to a :cease_or_revoke_form" do
            ceased_or_revoked_registration.workflow_state = :ceased_or_revoked_confirm_form

            ceased_or_revoked_registration.back

            expect(ceased_or_revoked_registration.workflow_state).to eq("cease_or_revoke_form")
          end
        end
      end
    end
  end
end
