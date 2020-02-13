# frozen_string_literal: true

RSpec.shared_examples "a simple monodirectional transition" do |previous_and_next_state:, current_state:, factory:|
  context "when a subject's state is #{current_state}" do
    subject(:subject) { create(factory, workflow_state: current_state) }

    it "can only transition to #{previous_and_next_state}" do
      permitted_states = Helpers::WorkflowStates.permitted_states(subject)
      expect(permitted_states).to match_array([previous_and_next_state])
    end

    it "changes to #{previous_and_next_state} after the 'next' event" do
      expect(subject).to transition_from(current_state).to(previous_and_next_state).on_event(:next)
    end

    it "changes to #{previous_and_next_state} after the 'back' event" do
      expect(subject).to transition_from(current_state).to(previous_and_next_state).on_event(:back)
    end
  end
end
