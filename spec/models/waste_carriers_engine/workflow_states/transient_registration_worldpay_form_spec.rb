require "rails_helper"

module WasteCarriersEngine
  RSpec.describe TransientRegistration, type: :model do
    describe "#workflow_state" do
      context "when a TransientRegistration's state is :worldpay_form" do
        let(:transient_registration) do
          create(:transient_registration,
                 :has_required_data,
                 :has_conviction_search_result,
                 :has_key_people,
                 workflow_state: "worldpay_form")
        end

        it "changes to :payment_summary_form after the 'back' event" do
          expect(transient_registration).to transition_from(:worldpay_form).to(:payment_summary_form).on_event(:back)
        end

        context "when there are no convictions" do
          before(:each) { transient_registration.declared_convictions = false }

          context "when the convictionSearchResults have no matches" do
            it "changes to :renewal_complete_form after the 'next' event" do
              expect(transient_registration).to transition_from(:worldpay_form).to(:renewal_complete_form).on_event(:next)
            end
          end

          context "when the convictionSearchResult has a match" do
            before(:each) { transient_registration.convictionSearchResult = build(:convictionSearchResult, :match_result_yes) }

            it "changes to :renewal_received_form after the 'next' event" do
              expect(transient_registration).to transition_from(:worldpay_form).to(:renewal_received_form).on_event(:next)
            end
          end

          context "when a keyPerson's convictionSearchResult has a match" do
            before(:each) { transient_registration.keyPeople << build(:key_person, :main, :matched_conviction_search_result) }

            it "changes to :renewal_received_form after the 'next' event" do
              expect(transient_registration).to transition_from(:worldpay_form).to(:renewal_received_form).on_event(:next)
            end
          end
        end

        context "when there are convictions" do
          before(:each) { transient_registration.declared_convictions = true }

          it "changes to :renewal_received_form after the 'next' event" do
            expect(transient_registration).to transition_from(:worldpay_form).to(:renewal_received_form).on_event(:next)
          end
        end
      end
    end
  end
end
