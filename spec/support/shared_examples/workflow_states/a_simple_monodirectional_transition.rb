# frozen_string_literal: true

# TODO: Kill this and use `has back transition` and `has next transition` instead
RSpec.shared_examples "a simple monodirectional transition" do |previous_and_next_state:, current_state:, factory:|
  context "when a subject's state is #{current_state}" do
    subject(:subject) { build(factory) }

    it "changes to #{previous_and_next_state} after the 'next' event" do
      expect(subject).to transition_from(current_state).to(previous_and_next_state).on_event(:next)
    end

    it "changes to #{previous_and_next_state} after the 'back' event" do
      expect(subject).to transition_from(current_state).to(previous_and_next_state).on_event(:back)
    end
  end
end
