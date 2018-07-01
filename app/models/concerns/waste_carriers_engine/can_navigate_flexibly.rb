module WasteCarriersEngine
  # The standard behaviour for loading a form is to check whether the requested form matches the workflow_state for
  # the transient registration, and redirect to the saved workflow_state if it doesn't.
  # But if the workflow state is 'flexible', we skip the check and load the requested form instead of the saved one.
  # This means users can still navigate by using the browser back button and reload forms which don't match the
  # saved workflow_state. We then update the workflow_state to match their request, rather than the other way around.
  # These are generally forms after 'renewal_start_form' but before 'declaration_form'.
  # Any form objects including this concern are considered to be 'flexible' by the FormsController.
  module CanNavigateFlexibly
    extend ActiveSupport::Concern
  end
end
