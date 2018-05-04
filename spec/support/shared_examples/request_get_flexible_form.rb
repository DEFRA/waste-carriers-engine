# ----
# This behaviour has not yet been implemented, so these tests are just an indication of what will happen.
# ----

# A 'flexible' form is a form that we don't mind users getting to via the back button.
# Getting to this form too early by URL-hacking might cause problems for the user,
# but we know that we will be validating the entire transient_registration later in the
# journey, so there is no risk of dodgy data or the user skipping essential steps.
# If the user loads one of these forms, we change the workflow_state to match their request,
# so the browser and the database agree about what form the user is currently using.
RSpec.shared_examples "GET flexible form" do |form, valid_params, invalid_params|
  context "when a valid user is signed in" do
    let(:user) { create(:user) }
    before(:each) do
      sign_in(user)
    end

    context "when no renewal is in progress" do
      it "redirects to the renewal_start_form" do
      end
    end

    context "when a renewal is in progress" do
      context "when the workflow_state is not a locked_in page" do
        it "updates the workflow_state to match the requested page" do
          skip("to be implemented")
        end

        it "loads the requested page" do
          skip("to be implemented")
        end
      end

      # Once users are in a locked-in workflow state, for example, the end of the journey,
      # we don't want them to be able to skip back to an earlier page any more.
      context "when the workflow_state is a locked-in page" do
        it "redirects to the workflow_state" do
          skip("to be implemented")
        end
      end
    end
  end
end
