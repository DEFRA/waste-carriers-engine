require "rails_helper"

module WasteCarriersEngine
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

    before do
      current_user = build(:user)
      FinanceDetails.new_finance_details(transient_registration, :worldpay, current_user)
      Payment.new_from_worldpay(transient_registration.finance_details.orders.first, current_user)
      registration.update_attributes(finance_details: build(:finance_details,
                                                            :has_required_data,
                                                            :has_order_and_payment))
    end

    describe "complete_renewal" do
      context "when the renewal is valid" do
        it "creates a new past_registration" do
          number_of_past_registrations = registration.past_registrations.count
          renewal_completion_service.complete_renewal
          expect(registration.reload.past_registrations.count).to eq(number_of_past_registrations + 1)
        end

        it "copies attributes from the transient_registration to the registration" do
          renewal_completion_service.complete_renewal
          expect(registration.reload.company_name).to eq(transient_registration.company_name)
        end

        it "copies nested attributes from the transient_registration to the registration" do
          registration.registered_address.update_attributes(postcode: "FOO")
          renewal_completion_service.complete_renewal
          expect(registration.reload.registered_address.postcode).to eq(transient_registration.registered_address.postcode)
        end

        it "adds the order from the transient_registration" do
          new_order = transient_registration.finance_details.orders.first
          renewal_completion_service.complete_renewal
          expect(registration.reload.finance_details.orders).to include(new_order)
        end

        it "adds the payment from the transient_registration" do
          new_payment = transient_registration.finance_details.payments.first
          renewal_completion_service.complete_renewal
          expect(registration.reload.finance_details.payments).to include(new_payment)
        end

        it "keeps existing orders" do
          old_order = registration.finance_details.orders.first
          renewal_completion_service.complete_renewal
          expect(registration.reload.finance_details.orders).to include(old_order)
        end

        it "keeps existing payments" do
          old_payment = registration.finance_details.payments.first
          renewal_completion_service.complete_renewal
          expect(registration.reload.finance_details.payments).to include(old_payment)
        end

        it "updates the balance" do
          old_balance = registration.finance_details.balance
          renewal_completion_service.complete_renewal
          expect(registration.reload.finance_details.balance).to_not eq(old_balance)
        end

        # This only applies to attributes where a value could be set, but not always - for example, smart answers
        context "if the registration has an attribute which is not in the transient_registration" do
          before do
            registration.update_attributes(construction_waste: true)
          end

          it "updates the attribute to be nil in the registration" do
            renewal_completion_service.complete_renewal
            expect(registration.reload.construction_waste).to eq(nil)
          end
        end

        it "updates the registration's expiry date" do
          old_expiry_date = registration.expires_on
          renewal_completion_service.complete_renewal
          expect(registration.reload.expires_on).to eq(old_expiry_date + 3.years)
        end

        it "updates the registration's last_modified" do
          old_last_modified = registration.metaData.last_modified
          renewal_completion_service.complete_renewal
          expect(registration.reload.metaData.last_modified).to_not eq(old_last_modified)
        end

        context "when the metadata_route is set" do
          before do
            allow(Rails.configuration).to receive(:metadata_route).and_return("ASSISTED_DIGITAL")
          end

          it "updates the registration's route to the correct value" do
            renewal_completion_service.complete_renewal
            expect(registration.reload.metaData.route).to eq("ASSISTED_DIGITAL")
          end
        end

        it "deletes the transient registration" do
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
end
