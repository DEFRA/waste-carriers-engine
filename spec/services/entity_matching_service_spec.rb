require "rails_helper"

RSpec.describe EntityMatchingService do
  let(:transient_registration) do
    create(:transient_registration,
           :has_required_data,
           :has_matching_convictions)
  end

  let(:entity_matching_service) { EntityMatchingService.new(transient_registration) }

  describe "check_business_for_matches" do
    context "when there is no company_no" do
      before do
        transient_registration.company_no = nil
      end

      let(:match_data) do
        {
          "confirmed" => "no",
          "confirmed_at" => nil,
          "confirmed_by" => nil,
          "match_result" => "NO",
          "matched_name" => nil,
          "matching_system" => nil,
          "reference" => nil
        }
      end

      it "returns the correct data" do
        VCR.use_cassette("entity_matching_business_has_matches") do
          expect(entity_matching_service.check_business_for_matches).to include(match_data)
        end
      end
    end
  end

  describe "check_people_for_matches" do
    context "when there is a match" do
      let(:match_data) do
        {
          "confirmed" => "no",
          "confirmed_at" => nil,
          "confirmed_by" => nil,
          "match_result" => "YES",
          "matched_name" => "Blogs, Fred",
          "matching_system" => "ABC",
          "reference" => "1234"
        }
      end

      it "returns the correct data" do
        VCR.use_cassette("entity_matching_person_has_matches") do
          expect(entity_matching_service.check_people_for_matches).to include(match_data)
        end
      end
    end
  end
end
