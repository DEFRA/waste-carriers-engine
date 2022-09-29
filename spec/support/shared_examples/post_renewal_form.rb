# frozen_string_literal: true

# When a user submits a form, that form must match the expected workflow_state.
# We don't adjust the state to match what the user is doing like we do for viewing forms.

# We expect to receive the name of the form (for example, location_form), and a set of options.
# Options can include valid params, invalid params, and an attribute to test persistence.
RSpec.shared_examples "POST renewal form" do |form, options|
  let(:valid_params) { options[:valid_params] }
  let(:invalid_params) { options[:invalid_params] }
  # Default to :reg_identifier for forms which don't submit new data.
  let(:test_attribute) { options.fetch(:test_attribute, :reg_identifier) }
  let(:expected_value) { options[:expected_value] }
  let(:user) { create(:user) }

  before do
    sign_in(user)
  end

  context "when no transient registration is found" do
    it "does not create a transient registration and redirects to the invalid page" do
      count = WasteCarriersEngine::TransientRegistration.count

      post_form_with_params(form, "foo")

      expect(WasteCarriersEngine::TransientRegistration.count).to eq(count)
      expect(response).to redirect_to(page_path("invalid"))
    end
  end

  context "when a renewal is in progress" do
    let(:transient_registration) do
      create(:renewing_registration,
             :has_required_data,
             account_email: user.email)
    end

    context "when the workflow_state matches the requested form" do
      before do
        transient_registration.update_attributes(workflow_state: form)
      end

      context "when the params are valid" do
        # NOTE: Keep me and put in shared POST.
        # Fix so we test all persisted data. Data comes from options.
        it "updates the transient registration, changes the workflow_state and redirects to the next page" do
          # If we've specified the value we want to get after updating, use that
          # Otherwise, expect the value submitted in params
          expected_value = valid_params[test_attribute] unless expected_value.present?
          state_before_request = transient_registration[:workflow_state]

          post_form_with_params(form, transient_registration.token, valid_params)
          expect(transient_registration.reload[test_attribute]).to eq(expected_value)
          expect(transient_registration.reload[:workflow_state]).not_to eq(state_before_request)
          expect(response).to have_http_status(:found)
        end
      end

      context "when the params are invalid" do
        before { transient_registration.update_attributes(tier: WasteCarriersEngine::Registration::LOWER_TIER) }

        it "does not update the transient registration, including workflow_state, and shows the form again" do
          transient_reg_before_submitting = transient_registration

          post_form_with_params(form, transient_registration.token, invalid_params)

          expect(transient_registration.reload).to eq(transient_reg_before_submitting)
          expect(response).to render_template("#{form}s/new")
        end
      end

      context "when the params are empty" do
        # NOTE: Kill it
        it "does not throw an error" do
          # rubocop:disable Style/BlockDelimiters
          expect {
            post_form_with_params(form, transient_registration.token)
          }.not_to raise_error
          # rubocop:enable Style/BlockDelimiters
        end
      end

      context "when the registration cannot be renewed" do
        before { transient_registration.update_attributes(expires_on: Date.today - Helpers::GraceWindows.current_grace_window) }

        it "does not update the transient registration, including workflow_state, and redirects to the unrenewable error page" do
          transient_reg_before_submitting = transient_registration

          post_form_with_params(form, transient_registration.token, valid_params)

          expect(transient_registration.reload).to eq(transient_reg_before_submitting)
          expect(response).to redirect_to(page_path("unrenewable"))
        end
      end
    end

    # Externalise is own shared scenario
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

      it "does not update the transient_registration, including workflow_state, and redirects to the correct form for the workflow_state" do
        transient_reg_before_submitting = transient_registration
        workflow_state = transient_registration[:workflow_state]

        post_form_with_params(form, transient_registration.token, valid_params)

        expect(transient_registration.reload).to eq(transient_reg_before_submitting)
        expect(response).to redirect_to(new_path_for(workflow_state, transient_registration))
      end
    end
  end

  # Should call a method like new_location_form_path("CBDU1234")
  def new_path_for(form, transient_registration)
    send("new_#{form}_path", transient_registration.token)
  end
end
