require "rails_helper"

RSpec.describe RenewalStartForm, type: :model do
  describe "#reg_identifier" do
    context "when a valid transient registration exists" do
      let(:renewal_start_form) { build(:renewal_start_form, :has_required_data) }

      context "when a reg_identifier meets the requirements" do
        before(:each) do
          renewal_start_form.reg_identifier = "CBDU1"
        end

        it "is valid" do
          expect(renewal_start_form).to be_valid
        end
      end

      context "when a reg_identifier is blank" do
        before(:each) do
          renewal_start_form.reg_identifier = ""
        end

        it "is not valid" do
          expect(renewal_start_form).to_not be_valid
        end
      end
    end
  end
end
