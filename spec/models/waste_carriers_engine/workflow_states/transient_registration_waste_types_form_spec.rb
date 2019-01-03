# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe TransientRegistration, type: :model do
    describe "#workflow_state" do
      context "when a TransientRegistration's state is :waste_types_form" do
        let(:transient_registration) do
          create(:transient_registration,
                 :has_required_data,
                 workflow_state: "waste_types_form")
        end

        it "transitions to :service_provided_form after the 'back' event" do
          expect(transient_registration).to transition_from(:waste_types_form).to(:service_provided_form).on_event(:back)
        end

        it "transitions to :cbd_type_form after the 'next' event" do
          expect(transient_registration).to transition_from(:waste_types_form).to(:cbd_type_form).on_event(:next)
        end
      end
    end
  end
end
