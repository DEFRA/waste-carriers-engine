# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe TransientRegistration, type: :model do
    describe "#workflow_state" do
      context "when a TransientRegistration's state is :renewal_received_form" do
        let(:transient_registration) do
          create(:transient_registration,
                 :has_required_data,
                 workflow_state: "renewal_received_form")
        end

        it "does not respond to the 'back' event" do
          expect(transient_registration).to_not allow_event :back
        end

        it "does not respond to the 'next' event" do
          expect(transient_registration).to_not allow_event :next
        end
      end
    end
  end
end
