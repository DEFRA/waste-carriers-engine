RSpec.shared_examples "form requests" do
  # The path for the renewal start form also acts as the re-entry point into the journey,
  # for example, if the user comes back to the renewals app via the dashboard.
  # So we should try to re-introduce them to the journey at the point where they left off.
  shared_examples_for "GET renewal_start_form" do
    context "when no renewal is in progress" do
      it "redirects to the renewal_start_form" do
      end
    end

    context "when a renewal is in progress" do
      it "redirects to the workflow_state" do
      end
    end
  end

  # A 'locked-in' form is a form we definitely don't want users to access out-of-order,
  # for example, by clicking the back button or URL-hacking.
  # Users shouldn't be able to get into locked-in forms this way.
  # They also shouldn't be able to get out of them, except by using buttons within the app.
  # This prevents users from skipping past the payment stage, or trying to go back and
  # make changes to their information after they've completed a renewal.
  shared_examples_for "GET locked-in form" do
    context "when no renewal is in progress" do
      it "redirects to the renewal_start_form" do
      end
    end

    context "when a renewal is in progress" do
      it "redirects to the saved workflow_state" do
      end

      it "does not change the workflow_state" do
      end
    end
  end

  # A 'flexible' form is a form that we don't mind users getting to via the back button.
  # Getting to this form too early by URL-hacking might cause problems for the user,
  # but we know that we will be validating the entire transient_registration later in the
  # journey, so there is no risk of dodgy data or the user skipping essential steps.
  # If the user loads one of these forms, we change the workflow_state to match their request,
  # so the browser and the database agree about what form the user is currently using.
  shared_examples_for "GET flexible form" do
    context "when no renewal is in progress" do
      it "redirects to the renewal_start_form" do
      end
    end

    context "when a renewal is in progress" do
      context "when the workflow_state is not a locked_in page" do
        it "updates the workflow_state to match the requested page" do
        end

        it "loads the requested page" do
        end
      end

      # Once users are in a locked-in workflow state, for example, the end of the journey,
      # we don't want them to be able to skip back to an earlier page any more.
      context "when the workflow_state is a locked-in page" do
        it "redirects to the workflow_state" do
        end
      end
    end
  end

  # When a user submits a form, that form must match the expected workflow_state.
  # We don't adjust the state to match what the user is doing like we do for viewing forms.
  shared_examples_for "POST" do
    context "when no renewal is in progress" do
      it "redirects to the renewal_start_form" do
      end

      it "does not save any data" do
      end
    end

    context "when a renewal is in progress" do
      context "when the workflow_state matches the requested form" do
        context "when the params are valid" do
          it "updates the transient registration" do
          end

          it "calls 'next' on the workflow_state" do
          end

          it "redirects to the next page" do
          end
        end

        context "when the params are invalid" do
          it "does not update the transient registration" do
          end

          it "does not change the workflow_state" do
          end

          it "redirects to the requested form" do
          end
        end
      end

      context "when the workflow_state does not match the requested form" do
        it "does not change the workflow_state" do
        end

        it "does not update the transient registration" do
        end

        it "does not call 'next' on the workflow_state" do
        end

        it "redirects to the correct form for the workflow_state" do
        end
      end
    end
  end
end
