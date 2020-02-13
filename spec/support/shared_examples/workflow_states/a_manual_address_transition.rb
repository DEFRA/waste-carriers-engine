# frozen_string_literal: true

RSpec.shared_examples "a manual address transition" do |previous_state_if_overseas:, next_state:, address_type:, factory:|
  describe "#workflow_state" do
    current_state = "#{address_type}_address_manual_form".to_sym
    subject(:subject) { create(factory, workflow_state: current_state) }

    context "when subject.overseas? is false" do
      previous_state_if_uk = "#{address_type}_postcode_form".to_sym

      before(:each) { subject.location = "england" }

      it "can only transition to either #{previous_state_if_uk} or #{next_state}" do
        permitted_states = Helpers::WorkflowStates.permitted_states(subject)

        expect(permitted_states).to match_array([previous_state_if_uk, next_state])
      end

      it "changes to #{previous_state_if_uk} after the 'back' event" do
        expect(subject).to transition_from(current_state).to(previous_state_if_uk).on_event(:back)
      end

      it "changes to #{next_state} after the 'next' event" do
        expect(subject).to transition_from(current_state).to(next_state).on_event(:next)
      end
    end

    context "when subject.overseas? is true" do
      before(:each) { subject.location = "overseas" }

      it "can only transition to #{previous_state_if_overseas} or #{next_state}" do
        permitted_states = Helpers::WorkflowStates.permitted_states(subject)

        expect(permitted_states).to match_array([previous_state_if_overseas, next_state].uniq)
      end

      it "changes to #{previous_state_if_overseas} after the 'back' event" do
        expect(subject).to transition_from(current_state).to(previous_state_if_overseas).on_event(:back)
      end

      it "changes to #{next_state} after the 'next' event" do
        expect(subject).to transition_from(current_state).to(next_state).on_event(:next)
      end
    end
  end
end
