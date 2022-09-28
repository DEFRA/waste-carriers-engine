# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe RenewingRegistration, type: :model do
    subject do
      build(:renewing_registration,
            :has_required_data,
            workflow_state: "conviction_details_form")
    end

    describe "#workflow_state" do
      context "with :conviction_details_form state transitions" do
        context "with :next transition" do
          include_examples "has next transition", next_state: "contact_name_form"
        end
      end
    end
  end
end
