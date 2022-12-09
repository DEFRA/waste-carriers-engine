# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe RenewingRegistration, type: :model do
    subject do
      build(:renewing_registration,
            :has_required_data,
            workflow_state: "invalid_company_status_form")
    end

    describe "#workflow_state" do
      context "with :next transition" do
        include_examples "has next transition", next_state: :start_form
      end
    end
  end
end
