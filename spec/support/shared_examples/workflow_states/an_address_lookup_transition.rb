# frozen_string_literal: true

RSpec.shared_examples "an address lookup transition" do |next_state_if_not_skipping_to_manual:, address_type:, factory:|
  describe "#workflow_state" do
    previous_state = "#{address_type}_postcode_form".to_sym
    current_state = "#{address_type}_address_form".to_sym
    subject(:subject) do
      create(factory, workflow_state: current_state,
                      tier: defined?(tier) ? tier : WasteCarriersEngine::Registration::UPPER_TIER)
    end

    context "when subject.skip_to_manual_address? is false" do
      next_state = next_state_if_not_skipping_to_manual
      alt_state = "#{address_type}_address_manual_form".to_sym

      before(:each) { subject.temp_os_places_error = nil }

      it "changes to #{next_state} after the 'next' event" do

        expect(subject).to transition_from(current_state).to(next_state).on_event(:next)
      end

      it "changes to #{alt_state} after the 'skip_to_manual_address' event" do
        expect(subject)
          .to transition_from(current_state)
          .to(alt_state)
          .on_event(:skip_to_manual_address)
      end

      it "changes to #{previous_state} after the 'back' event" do
        expect(subject).to transition_from(current_state).to(previous_state).on_event(:back)
      end
    end

    context "when subject.skip_to_manual_address? is true" do
      next_state = "#{address_type}_address_manual_form".to_sym

      before(:each) { subject.temp_os_places_error = true }

      it "changes to #{next_state} after the 'next' event" do
        expect(subject).to transition_from(current_state).to(next_state).on_event(:next)
      end

      it "changes to #{next_state} after the 'skip_to_manual_address' event" do
        expect(subject)
          .to transition_from(current_state)
          .to(next_state)
          .on_event(:skip_to_manual_address)
      end

      it "changes to #{previous_state} after the 'back' event" do
        expect(subject).to transition_from(current_state).to(previous_state).on_event(:back)
      end
    end
  end
end
