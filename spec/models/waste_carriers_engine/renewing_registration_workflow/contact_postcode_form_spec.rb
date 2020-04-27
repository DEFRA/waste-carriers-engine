# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe RenewingRegistration do
    describe "#workflow_state" do
      it_behaves_like "a postcode transition",
                      previous_state: :contact_email_form,
                      address_type: "contact",
                      factory: :renewing_registration
    end
  end
end
