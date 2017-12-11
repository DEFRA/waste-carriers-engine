require "rails_helper"

RSpec.describe TransientRegistration, type: :model do
  describe "#workflow_state" do
    context "when a TransientRegistration is created" do
      let(:transient_registration) do
        create(:transient_registration,
               :has_required_data)
      end

      it "has the state :renewal_start" do
        expect(transient_registration).to have_state(:renewal_start)
      end
    end

    context "when a TransientRegistration's state is :renewal_start" do
      let(:transient_registration) do
        create(:transient_registration,
               :has_required_data,
               workflow_state: "renewal_start")
      end

      it "changes state to :business_type after the 'next' event" do
        expect(transient_registration).to transition_from(:renewal_start).to(:business_type).on_event(:next)
      end
    end

    context "when a TransientRegistration's state is :business_type" do
      let(:transient_registration) do
        create(:transient_registration,
               :has_required_data,
               workflow_state: "business_type")
      end

      it "changes state to :renewal_start after the 'back' event" do
        expect(transient_registration).to transition_from(:business_type).to(:renewal_start).on_event(:back)
      end
    end
  end
end
