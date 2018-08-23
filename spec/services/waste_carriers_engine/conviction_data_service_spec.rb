require "rails_helper"

module WasteCarriersEngine
  RSpec.describe ConvictionDataService do
    let(:transient_registration) do
      create(:transient_registration,
             :has_required_data)
    end

    let(:conviction_data_service) { ConvictionDataService.new(transient_registration) }

    before do
      allow_any_instance_of(EntityMatchingService).to receive(:check_business_for_matches).and_return(false)
      allow_any_instance_of(EntityMatchingService).to receive(:check_people_for_matches).and_return(false)
    end

    describe "prepare_convictions_data" do
      context "when the user has not declared convictions" do
        before do
          transient_registration.declared_convictions = "no"
        end

        context "when there is no match" do
          before do
            transient_registration.conviction_search_result = build(:conviction_search_result, :match_result_no)
            transient_registration.key_people = [build(:key_person, :unmatched_conviction_search_result)]
          end

          it "does not create a conviction_search_result" do
            conviction_data_service.prepare_convictions_data
            expect(transient_registration.reload.conviction_sign_offs).to_not exist
          end
        end

        context "when there is a match against the business" do
          before do
            transient_registration.conviction_search_result = build(:conviction_search_result, :match_result_yes)
            transient_registration.key_people = [build(:key_person, :unmatched_conviction_search_result)]
          end

          it "creates a conviction_search_result" do
            conviction_data_service.prepare_convictions_data
            expect(transient_registration.reload.conviction_sign_offs).to exist
          end
        end

        context "when there is a match against a person" do
          before do
            transient_registration.conviction_search_result = build(:conviction_search_result, :match_result_no)
            transient_registration.key_people = [build(:key_person, :matched_conviction_search_result)]
          end

          it "creates a conviction_search_result" do
            conviction_data_service.prepare_convictions_data
            expect(transient_registration.reload.conviction_sign_offs).to exist
          end
        end
      end

      context "when the user has declared convictions" do
        before do
          transient_registration.declared_convictions = "yes"
        end

        context "when there is no match" do
          before do
            transient_registration.conviction_search_result = build(:conviction_search_result, :match_result_no)
            transient_registration.key_people = [build(:key_person, :unmatched_conviction_search_result)]
          end

          it "creates a conviction_search_result" do
            conviction_data_service.prepare_convictions_data
            expect(transient_registration.reload.conviction_sign_offs).to exist
          end
        end

        context "when there is a match against the business" do
          before do
            transient_registration.conviction_search_result = build(:conviction_search_result, :match_result_yes)
            transient_registration.key_people = [build(:key_person, :unmatched_conviction_search_result)]
          end

          it "creates a conviction_search_result" do
            conviction_data_service.prepare_convictions_data
            expect(transient_registration.reload.conviction_sign_offs).to exist
          end
        end

        context "when there is a match against a person" do
          before do
            transient_registration.conviction_search_result = build(:conviction_search_result, :match_result_no)
            transient_registration.key_people = [build(:key_person, :matched_conviction_search_result)]
          end

          it "creates a conviction_search_result" do
            conviction_data_service.prepare_convictions_data
            expect(transient_registration.reload.conviction_sign_offs).to exist
          end
        end
      end
    end
  end
end
