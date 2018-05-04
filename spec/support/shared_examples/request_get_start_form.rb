# The path for the renewal start form also acts as the re-entry point into the journey,
# for example, if the user comes back to the renewals app via the dashboard.
# So we should try to re-introduce them to the journey at the point where they left off.
RSpec.shared_examples "GET start form" do |form, valid_params, invalid_params|
  context "when a valid user is signed in" do
    let(:user) { create(:user) }
    before(:each) do
      sign_in(user)
    end

    context "when no renewal is in progress" do
      it "redirects to the renewal_start_form" do
        skip("to be implemented")
      end
    end

    context "when a renewal is in progress" do
      it "redirects to the workflow_state" do
        skip("to be implemented")
      end
    end
  end
end
