require "rails_helper"

RSpec.describe RenewalStartForm, type: :model do
  describe "#reg_identifier" do
    context "when a valid transient registration exists" do
      let(:registration) { create(:registration, :has_required_data) }
      let(:transient_registration) {
        build(:transient_registration, reg_identifier: registration.reg_identifier)
      }
      # Don't use FactoryBot for this as we need to make sure it initializes with a specific object
      let(:renewal_start_form) { RenewalStartForm.new(transient_registration) }

      context "when a reg_identifier meets the requirements" do
        before(:each) do
          renewal_start_form.reg_identifier = transient_registration.reg_identifier
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
