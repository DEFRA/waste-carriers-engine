require "rails_helper"

RSpec.describe ApplicationHelper, type: :helper do
  describe "feedback_survey_url" do
    it "returns a correctly-formatted URL" do
      expect(ApplicationHelper.feedback_survey_url("foo")).to eq("https://www.smartsurvey.co.uk/s/waste-carriers/?referringpage=foo")
    end
  end

  describe "#current_git_commit" do
    it "returns nil when run in the test environment" do
      expect(helper.current_git_commit).to eq(nil)
    end
  end
end
