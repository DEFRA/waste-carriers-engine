require "rails_helper"

RSpec.describe RenewalCompletionService do
  let(:transient_registration) do
     create(:transient_registration,
            :has_required_data,
            :has_addresses,
            :has_key_people,
            company_name: "FooBiz",
            workflow_state: "renewal_complete_form")
  end
  let(:registration) { Registration.where(reg_identifier: transient_registration.reg_identifier).first }

  let(:renewal_completion_service) { RenewalCompletionService.new(transient_registration) }

  describe "complete_renewal" do
    context "when the renewal is valid" do
      it "creates a new past_registration" do
        number_of_past_registrations = registration.past_registrations.count
        renewal_completion_service.complete_renewal
        expect(registration.reload.past_registrations.count).to eq(number_of_past_registrations + 1)
      end

      it "copies data from the transient_registration to the registration" do
        pending("To be implemented")

        renewal_completion_service.complete_renewal
        expect(registration.company_name).to eq(transient_registration.company_name)
      end

      it "updates the registration's expiry date" do
        pending("To be implemented")

        old_expiry_date = registration.expires_on
        renewal_completion_service.complete_renewal
        expect(registration.expires_on).to eq(old_expiry_date + 3.years)
      end

      it "deletes the transient registration" do
        pending("To be implemented")

        renewal_completion_service.complete_renewal
        expect(TransientRegistration.where(reg_identifier: transient_registration.reg_identifier).count).to eq(0)
      end
    end

    context "when the renewal is not valid" do
      before do
        registration.metaData.update_attributes(status: "REJECTED")
      end

      it "returns :error" do
        expect(renewal_completion_service.complete_renewal).to eq(:error)
      end
    end
  end
end
