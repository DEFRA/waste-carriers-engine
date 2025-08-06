# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe NewRegistration do
    subject { build(:new_registration, workflow_state: "contact_phone_form") }

    describe "#workflow_state" do
      context "with :contact_phone_form state transitions" do
        context "with :next transition" do
          it_behaves_like "has next transition", next_state: "contact_email_form"
        end
      end
    end
  end
end
