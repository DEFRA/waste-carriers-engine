# frozen_string_literal: true

module WasteCarriersEngine
  class BaseForm
    include ActiveModel::Model
    include CanStripWhitespace
    attr_accessor :reg_identifier, :transient_registration

    # The standard behaviour for loading a form is to check whether the requested form matches the workflow_state for
    # the registration, and redirect to the saved workflow_state if it doesn't.
    # But if the workflow state is 'flexible', we skip the check and load the requested form instead of the saved one.
    # This means users can still navigate by using the browser back button and reload forms which don't match the
    # saved workflow_state. We then update the workflow_state to match their request, rather than the other way around.
    # These are generally forms after 'start_form' but before 'declaration_form'.
    # Any form objects including this concern are considered to be 'flexible' by the FormsController.
    def self.can_navigate_flexibly?
      # This can be overriden in a subclass if one requires the avoidance of flexible navigation.
      true
    end

    def initialize(transient_registration)
      # Get values from transient registration so form will be pre-filled
      @transient_registration = transient_registration
      self.reg_identifier = @transient_registration.reg_identifier
    end

    def submit(attributes, reg_identifier)
      # Additional attributes are set in individual form subclasses
      self.reg_identifier = reg_identifier

      attributes = strip_whitespace(attributes)

      # Update the transient registration with params from the registration if valid
      if valid?
        @transient_registration.update_attributes(attributes)
        @transient_registration.save!
        true
      else
        false
      end
    end

    validates :reg_identifier, "waste_carriers_engine/reg_identifier": true
    validate :transient_registration_valid?

    private

    def transient_registration_valid?
      return if @transient_registration.valid?

      @transient_registration.errors.each do |_attribute, message|
        errors[:base] << message
      end
    end
  end
end
