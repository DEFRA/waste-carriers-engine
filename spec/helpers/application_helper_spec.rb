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

  describe "display_pence_as_pounds" do
    context "when the value in pence is an integer in pounds" do
      it "returns the correct value without decimal places" do
        expect(helper.display_pence_as_pounds(500)).to eq("5")
      end
    end

    context "when the value in pence is not an integer in pounds" do
      it "returns the correct value with 2 decimal places" do
        expect(helper.display_pence_as_pounds(550)).to eq("5.50")
      end
    end
  end
end
