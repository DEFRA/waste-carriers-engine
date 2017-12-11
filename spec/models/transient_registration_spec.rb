require "rails_helper"

RSpec.describe TransientRegistration, type: :model do
  describe "#workflow_state" do
    context "when a TransientRegistration is created" do
      let(:transient_registration) do
        create(:transient_registration,
               :has_required_data)
      end

      it "has the state :renewal_start_page" do
        expect(transient_registration).to have_state(:renewal_start_page)
      end
    end

    context "when a TransientRegistration's state is :renewal_start_page" do
      let(:transient_registration) do
        create(:transient_registration,
               :has_required_data,
               workflow_state: "renewal_start_page")
      end

      it "changes state to :business_type_page after the 'next' event" do
        expect(transient_registration).to transition_from(:renewal_start_page).to(:business_type_page).on_event(:next)
      end
    end

    context "when a TransientRegistration's state is :business_type_page" do
      let(:transient_registration) do
        create(:transient_registration,
               :has_required_data,
               workflow_state: "business_type_page")
      end

      it "changes state to :renewal_start_page after the 'back' event" do
        expect(transient_registration).to transition_from(:business_type_page).to(:renewal_start_page).on_event(:back)
      end
    end
  end
end
