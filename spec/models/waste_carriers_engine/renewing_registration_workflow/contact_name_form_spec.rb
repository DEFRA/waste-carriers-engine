# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe RenewingRegistration, type: :model do
    subject do
      build(:renewing_registration,
            :has_required_data,
            declared_convictions: declared_convictions,
            workflow_state: "contact_name_form")
    end
    let(:declared_convictions) { nil }

    describe "#workflow_state" do
      context "with :contact_name_form state transitions" do
        context "with :next transition" do
          include_examples "has next transition", next_state: "contact_phone_form"
        end
      end
    end
  end
end
