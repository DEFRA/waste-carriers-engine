# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe RenewingRegistration, type: :model do
    describe "#workflow_state" do
      context "when a RenewingRegistration's state is :conviction_details_form" do
        let(:transient_registration) do
          create(:renewing_registration,
                 :has_required_data,
                 workflow_state: "conviction_details_form")
        end

        it "changes to :declare_convictions_form after the 'back' event" do
          expect(transient_registration).to transition_from(:conviction_details_form).to(:declare_convictions_form).on_event(:back)
        end

        it "changes to :contact_name_form after the 'next' event" do
          expect(transient_registration).to transition_from(:conviction_details_form).to(:contact_name_form).on_event(:next)
        end
      end
    end
  end
end
