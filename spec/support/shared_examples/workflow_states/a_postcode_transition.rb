# frozen_string_literal: true

RSpec.shared_examples "a postcode transition" do |address_type:, factory:|
  describe "#workflow_state" do
    current_state = "#{address_type}_postcode_form".to_sym
    subject(:subject) do
      create(factory, workflow_state: current_state,
                      tier: defined?(tier) ? tier : WasteCarriersEngine::Registration::UPPER_TIER)
    end

    context "when subject.skip_to_manual_address? is false" do
      next_state = "#{address_type}_address_form".to_sym
      alt_state = "#{address_type}_address_manual_form".to_sym

      before { subject.temp_os_places_error = nil }

      it "can only transition to either #{next_state} or #{alt_state}" do
        permitted_states = Helpers::WorkflowStates.permitted_states(subject)

        expect(permitted_states).to match_array([next_state, alt_state])
      end

      it "changes to #{next_state} after the 'next' event" do
        expect(subject).to transition_from(current_state).to(next_state).on_event(:next)
      end

      it "changes to #{alt_state} after the 'skip_to_manual_address' event" do
        expect(subject)
          .to transition_from(current_state)
          .to(alt_state)
          .on_event(:skip_to_manual_address)
      end
    end

    context "when subject.skip_to_manual_address? is true" do
      next_state = "#{address_type}_address_manual_form".to_sym

      before { subject.temp_os_places_error = true }

      it "can only transition to either #{next_state}" do
        permitted_states = Helpers::WorkflowStates.permitted_states(subject)

        expect(permitted_states).to match_array([next_state])
      end

      it "changes to #{next_state} after the 'next' event" do
        expect(subject).to transition_from(current_state).to(next_state).on_event(:next)
      end
    end
  end
end
