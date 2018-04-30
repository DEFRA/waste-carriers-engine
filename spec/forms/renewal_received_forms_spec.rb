require "rails_helper"

RSpec.describe RenewalReceivedForm, type: :model do
  describe "#reg_identifier" do
    context "when a valid transient registration exists" do
      let(:transient_registration) do
        create(:transient_registration,
               :has_required_data,
               workflow_state: "renewal_received_form")
      end
      # Don't use FactoryBot for this as we need to make sure it initializes with a specific object
      let(:renewal_received_form) { RenewalReceivedForm.new(transient_registration) }

      context "when a reg_identifier meets the requirements" do
        before(:each) do
          renewal_received_form.reg_identifier = transient_registration.reg_identifier
        end

        it "is valid" do
          expect(renewal_received_form).to be_valid
        end
      end

      context "when a reg_identifier is blank" do
        before(:each) do
          renewal_received_form.reg_identifier = ""
        end

        it "is not valid" do
          expect(renewal_received_form).to_not be_valid
        end
      end
    end
  end

  describe "#transient_registration" do
    context "when the transient registration is invalid" do
      let(:transient_registration) do
        build(:transient_registration,
              workflow_state: "renewal_received_form")
      end
      # Don't use FactoryBot for this as we need to make sure it initializes with a specific object
      let(:renewal_received_form) { RenewalReceivedForm.new(transient_registration) }

      before(:each) do
        # Make reg_identifier valid for the form, but not the transient object
        renewal_received_form.reg_identifier = transient_registration.reg_identifier
        transient_registration.reg_identifier = "foo"
      end

      it "is not valid" do
        expect(renewal_received_form).to_not be_valid
      end

      it "inherits the errors from the transient_registration" do
        renewal_received_form.valid?
        expect(renewal_received_form.errors[:base]).to include(I18n.t("mongoid.errors.models.transient_registration.attributes.reg_identifier.invalid_format"))
      end
    end
  end
end
