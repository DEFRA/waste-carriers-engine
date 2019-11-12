# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe RenewingRegistration, type: :model do
    describe "#workflow_state" do
      context "when a RenewingRegistration's state is :contact_phone_form" do
        let(:transient_registration) do
          create(:renewing_registration,
                 :has_required_data,
                 workflow_state: "contact_phone_form")
        end

        it "changes to :contact_name_form after the 'back' event" do
          expect(transient_registration).to transition_from(:contact_phone_form).to(:contact_name_form).on_event(:back)
        end

        it "changes to :contact_email_form after the 'next' event" do
          expect(transient_registration).to transition_from(:contact_phone_form).to(:contact_email_form).on_event(:next)
        end
      end
    end
  end
end
