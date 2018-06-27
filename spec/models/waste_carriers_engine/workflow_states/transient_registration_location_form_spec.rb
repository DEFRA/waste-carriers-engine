require "rails_helper"

RSpec.describe TransientRegistration, type: :model do
  describe "#workflow_state" do
    context "when a TransientRegistration's state is :location_form" do
      let(:transient_registration) do
        create(:transient_registration,
               :has_required_data,
               workflow_state: "location_form")
      end

      it "changes to :renewal_start_form after the 'back' event" do
        expect(transient_registration).to transition_from(:location_form).to(:renewal_start_form).on_event(:back)
      end

      context "when the 'next' event happens" do
        shared_examples_for "'next' transition from location_form" do |location, next_state|
          before(:each) do
            transient_registration.location = location
          end

          it "should transition to the correct next state" do
            expect(transient_registration).to transition_from(:location_form).to(next_state).on_event(:next)
          end
        end

        {
          # Permutation table of location and the state that should result
          "england"          => :business_type_form,
          "northern_ireland" => :register_in_northern_ireland_form,
          "scotland"         => :register_in_scotland_form,
          "wales"            => :register_in_wales_form,
          "overseas"         => :tier_check_form
        }.each do |location, next_form|
          it_behaves_like "'next' transition from location_form", location, next_form
        end
      end
    end
  end
end
