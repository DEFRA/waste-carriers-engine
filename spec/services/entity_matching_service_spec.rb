require "rails_helper"

RSpec.describe EntityMatchingService do
  let(:transient_registration) do
    create(:transient_registration,
           :has_required_data,
           :has_matching_convictions)
  end

  let(:entity_matching_service) { EntityMatchingService.new(transient_registration) }

  describe "check_business_for_matches" do
    it "returns the correct url" do
      url = "http://localhost:3003/match/company?number=12345678"
      expect(entity_matching_service.check_business_for_matches).to eq(url)
    end
  end

  describe "check_people_for_matches" do
    it "returns the correct url" do
      url = "http://localhost:3003/match/person?firstname=Fred&lastname=Blogs&dateofbirth=01-01-1981"
      expect(entity_matching_service.check_people_for_matches).to eq(url)
    end
  end
end
