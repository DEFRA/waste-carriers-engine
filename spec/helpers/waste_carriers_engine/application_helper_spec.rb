require "rails_helper"

module WasteCarriersEngine
  RSpec.describe WasteCarriersEngine::ApplicationHelper, type: :helper do
    describe "feedback_survey_url" do
      it "returns a correctly-formatted URL" do
        expect(WasteCarriersEngine::ApplicationHelper.feedback_survey_url("foo")).to eq("https://www.smartsurvey.co.uk/s/waste-carriers/?referringpage=foo")
      end
    end

    describe "title" do
      context "when a specific title is provided" do
        before do
          allow(helper).to receive(:content_for?).and_return(true)
          allow(helper).to receive(:content_for).and_return("Foo")
        end

        it "returns the correct full title" do
          expect(helper.title).to eq("Foo - Register as a waste carrier - GOV.UK")
        end
      end

      context "when no specific title is provided" do
        it "returns the correct full title" do
          expect(helper.title).to eq("Register as a waste carrier - GOV.UK")
        end
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

    describe "dashboard_link" do
      before do
        allow(Rails.configuration).to receive(:wcrs_frontend_url).and_return("http://www.example.com")
      end

      it "returns the correct value" do
        user = build(:user)
        expected_url = "http://www.example.com/user/#{user.id}/registrations"
        expect(helper.dashboard_link(user)).to eq(expected_url)
      end
    end

    describe "displayable_address" do
      let(:address) do
        build(:address,
              house_number: "5",
              address_line_1: "Foo Terrace",
              address_line_2: "Bar Street",
              town_city: "Bazville",
              postcode: "AB1 2CD",
              country: "Quxland")
      end

      it "returns the correct value" do
        expected_address = ["5", "Foo Terrace", "Bar Street", "Bazville", "AB1 2CD", "Quxland"]
        expect(displayable_address(address)).to eq(expected_address)
      end
    end
  end
end
