# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe RenewingRegistration do
    subject do
      build(:renewing_registration,
            :has_required_data,
            workflow_state: "register_in_wales_form")
    end

    describe "#workflow_state" do
      context "with :register_in_wales_form state transitions" do
        context "with :next transition" do
          it_behaves_like "has next transition", next_state: "business_type_form"
        end
      end
    end
  end
end
