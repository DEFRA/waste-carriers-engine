# frozen_string_literal: true

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

    context "when a renewal is in progress" do
      let(:transient_registration) do
        create(:renewing_registration,
               :has_required_data,
               :has_addresses,
               :has_key_people,
               account_email: user.email,
               workflow_state: form)
      end

      context "when the workflow_state matches the request" do
        it "loads the requested page" do
          get new_path_for(form, transient_registration)
          expect(response).to render_template("#{form}s/new")
        end
      end

      context "when the workflow_state is a flexible form" do
        let(:saved_state) do
          # We need to pick a different but also valid state for the transient_registration
          # 'waste_types_form' is the default, unless this would actually match!
          if form == "waste_types_form"
            "other_businesses_form"
          else
            "waste_types_form"
          end
        end

        before do
          transient_registration.update_attributes(workflow_state: saved_state)
        end

        it "updates the workflow_state to match the requested page" do
          get new_path_for(form, transient_registration)
          expect(transient_registration.reload[:workflow_state]).to eq(form)
        end

        it "loads the requested page" do
          get new_path_for(form, transient_registration)
          expect(response).to render_template("#{form}s/new")
        end
      end

      # Once users are in a locked-in workflow state, for example, the end of the journey,
      # we don't want them to be able to skip back to an earlier page any more.
      context "when the workflow_state is a locked-in form" do
        let(:saved_state) do
          "payment_summary_form"
        end

        before do
          transient_registration.update_attributes(workflow_state: saved_state)
        end

        it "redirects to the saved workflow_state" do
          workflow_state = transient_registration[:workflow_state]
          get new_path_for(form, transient_registration)
          expect(response).to redirect_to(new_path_for(workflow_state, transient_registration))
        end

        it "does not change the workflow_state" do
          get new_path_for(form, transient_registration)
          expect(transient_registration.reload[:workflow_state]).to eq(saved_state)
        end
      end
    end
  end

  # Should call a method like new_location_form_path("CBDU1234")
  def new_path_for(form, transient_registration)
    send("new_#{form}_path", transient_registration.token)
  end
end
