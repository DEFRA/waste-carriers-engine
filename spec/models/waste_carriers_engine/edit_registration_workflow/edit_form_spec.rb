# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe EditRegistration do
    subject(:edit_registration) { build(:edit_registration) }

    describe "#workflow_state" do
      context ":edit_form state transitions" do
        current_state = :edit_form
        editable_form_states = %i[
          cbd_type_form
          company_name_form
          main_people_form
          contact_name_form
          contact_phone_form
          contact_email_form
          location_form
        ]
        transitionable_states = editable_form_states + %i[declaration_form]

        context "when an EditRegistration's state is #{current_state}" do
          it "can only transition to the allowed states" do
            permitted_states = Helpers::WorkflowStates.permitted_states(edit_registration)
            expect(permitted_states).to match_array(transitionable_states)
          end

          editable_form_states.each do |expected_state|
            state_without_form_suffix = expected_state.to_s.remove("_form")
            event = "edit_#{state_without_form_suffix}".to_sym

            it "changes to #{expected_state} after the '#{event}' event" do
              expect(subject).to transition_from(current_state).to(expected_state).on_event(event)
            end
          end

          it "changes to declaration_form after the 'next' event" do
            expected_state = :declaration_form
            event = :next
            expect(subject).to transition_from(current_state).to(expected_state).on_event(event)
          end
        end
      end
    end
  end
end
