# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe RenewingRegistration, type: :model do
    subject do
      build(:renewing_registration,
            :has_required_data,
            workflow_state: "contact_phone_form")
    end

    describe "#workflow_state" do
      context ":contact_phone_form state transitions" do
        context "on next" do
          include_examples "has next transition", next_state: "contact_email_form"
        end
      end
    end
  end
end
