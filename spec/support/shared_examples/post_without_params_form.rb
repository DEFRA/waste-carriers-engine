# frozen_string_literal: true

# When a user submits a form, that form must match the expected workflow_state.
# We don't adjust the state to match what the user is doing like we do for viewing forms.

# We expect to receive the name of the form (for example, location_form),
# a set of valid params, a set of invalid params, and an attribute to test persistence
# Default to :reg_identifier for forms which don't submit new data
RSpec.shared_examples "POST without params form" do |form|
  context "when a valid user is signed in" do
    let(:user) { create(:user) }
    before(:each) do
      sign_in(user)
    end

    context "when the token is invalid" do
      it "redirects to the invalid page" do
        post_form_with_params(form, "foo")

        expect(response).to redirect_to(page_path("invalid"))
      end
    end

    context "when a renewal is in progress" do
      let(:transient_registration) do
        create(:renewing_registration,
               :has_required_data,
               :has_addresses,
               :has_key_people,
               :has_unpaid_balance,
               account_email: user.email)
      end

      context "when the workflow_state matches the requested form" do
        before do
          transient_registration.update_attributes(workflow_state: form)
        end

        context "when the params are valid" do
          it "changes the workflow_state" do
            state_before_request = transient_registration[:workflow_state]
            post_form_with_params(form, transient_registration.token)
            expect(transient_registration.reload[:workflow_state]).to_not eq(state_before_request)
          end

          it "redirects to the next page" do
            post_form_with_params(form, transient_registration.token)
            expect(response).to have_http_status(302)
          end
        end

        context "when the token is invalid" do
          it "redirects to the invalid error page" do
            post_form_with_params(form, "foo")

            expect(response).to redirect_to(page_path("invalid"))
          end
        end

        context "when the registration cannot be renewed" do
          before { transient_registration.update_attributes(expires_on: Date.today - Rails.configuration.grace_window) }

          it "does not update the transient registration, including workflow_state" do
            transient_reg_before_submitting = transient_registration
            post_form_with_params(form, transient_registration.token)
            expect(transient_registration.reload).to eq(transient_reg_before_submitting)
          end

          it "redirects to the unrenewable error page" do
            post_form_with_params(form, transient_registration.token)
            expect(response).to redirect_to(page_path("unrenewable"))
          end
        end
      end

      context "when the workflow_state does not match the requested form" do
        before do
          # We need to pick a different but also valid state for the transient_registration
          # 'payment_summary_form' is the default, unless this would actually match!
          different_state = if form == "payment_summary_form"
                              "other_businesses_form"
                            else
                              "payment_summary_form"
                            end
          transient_registration.update_attributes(workflow_state: different_state)
        end

        it "does not update the transient_registration, including workflow_state" do
          transient_reg_before_submitting = transient_registration
          post_form_with_params(form, transient_registration.token)
          expect(transient_registration.reload).to eq(transient_reg_before_submitting)
        end

        it "redirects to the correct form for the workflow_state" do
          workflow_state = transient_registration[:workflow_state]
          post_form_with_params(form, transient_registration.token)
          expect(response).to redirect_to(new_path_for(workflow_state, transient_registration))
        end
      end
    end
  end
end
