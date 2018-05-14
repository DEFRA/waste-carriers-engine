# ----
# This behaviour has not yet been implemented, so these tests are just an indication of what will happen.
# ----

# A 'flexible' form is a form that we don't mind users getting to via the back button.
# Getting to this form too early by URL-hacking might cause problems for the user,
# but we know that we will be validating the entire transient_registration later in the
# journey, so there is no risk of dodgy data or the user skipping essential steps.
# If the user loads one of these forms, we change the workflow_state to match their request,
# so the browser and the database agree about what form the user is currently using.
RSpec.shared_examples "GET flexible form" do |form|
  context "when a valid user is signed in" do
    let(:user) { create(:user) }
    before(:each) do
      sign_in(user)
    end

    context "when no renewal is in progress" do
      let(:registration) do
        create(:registration,
               :has_required_data,
               account_email: user.email)
      end

      it "redirects to the renewal_start_form" do
        get new_path_for(form, registration)
        expect(response).to redirect_to(new_renewal_start_form_path(registration[:reg_identifier]))
      end
    end

    context "when a renewal is in progress" do
      let(:transient_registration) do
        create(:transient_registration,
               :has_required_data,
               account_email: user.email)
      end

      context "when the workflow_state is not a locked_in page" do
        let(:requested_state) do
          # We need to pick a different but also valid state for the transient_registration
          # 'waste_types_forms' is the default, unless this would actually match!
          if form == "waste_types_forms"
            "other_businesses_form"
          else
            "waste_types_forms"
          end
        end

        before do
          transient_registration.update_attributes(workflow_state: requested_state)
        end

        it "updates the workflow_state to match the requested page" do
          get new_path_for(form, transient_registration)
          expect(transient_registration.reload[:workflow_state]).to eq(requested_state)
        end

        it "loads the requested page" do
          get new_path_for(form, transient_registration)
          expect(response).to redirect_to(new_path_for(requested_state, transient_registration))
        end
      end

      # Once users are in a locked-in workflow state, for example, the end of the journey,
      # we don't want them to be able to skip back to an earlier page any more.
      context "when the workflow_state is a locked-in page" do
        let(:requested_state) do
          # We need to pick a different but also valid state for the transient_registration
          # 'payment_summary_form' is the default, unless this would actually match!
          if form == "payment_summary_form"
            "bank_transfer_form"
          else
            "payment_summary_form"
          end
        end

        before do
          transient_registration.update_attributes(workflow_state: requested_state)
        end

        it "redirects to the saved workflow_state" do
          workflow_state = transient_registration[:workflow_state]
          get new_path_for(form, transient_registration)
          expect(response).to redirect_to(new_path_for(workflow_state, transient_registration))
        end

        it "does not change the workflow_state" do
          state_before_request = transient_registration[:workflow_state]
          get new_path_for(form, transient_registration)
          expect(transient_registration.reload[:workflow_state]).to eq(state_before_request)
        end
      end
    end
  end

  # Should call a method like new_location_form_path("CBDU1234")
  def new_path_for(form, transient_registration)
    reg_id = transient_registration[:reg_identifier] if transient_registration.present?
    send("new_#{form}_path", reg_id)
  end
end
