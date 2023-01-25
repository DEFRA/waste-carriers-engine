# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe ContactAddressManualForm do
    describe "#initialize" do
      context "when the transient registration has an address already" do
        let(:contact_address) { build(:address, :contact, :has_required_data) }
        let(:transient_registration) do
          build(
            :renewing_registration,
            workflow_state: "contact_address_manual_form",
            contact_address: contact_address
          )
        end
        # Don't use FactoryBot for this as we need to make sure it initializes with a specific object
        let(:contact_address_manual_form) { described_class.new(transient_registration) }

        context "when the business type is overseas" do
          before do
            transient_registration.business_type = "overseas"
          end

          it "prefills the form with the existing address" do
            expect(contact_address_manual_form.house_number).to eq(contact_address.house_number)
          end
        end

        context "when the temp_contact_postcode doesn't exist" do
          before do
            transient_registration.temp_contact_postcode = nil
          end

          it "prefills the form with the existing address" do
            expect(contact_address_manual_form.house_number).to eq(contact_address.house_number)
          end
        end

        context "when the temp_contact_postcode matches the existing address" do
          before do
            transient_registration.temp_contact_postcode = contact_address.postcode
          end

          it "prefills the form with the existing address" do
            expect(contact_address_manual_form.house_number).to eq(contact_address.house_number)
          end
        end

        context "when the temp_contact_postcode is in use and doesn't match the registered address" do
          before do
            transient_registration.temp_contact_postcode = "foo"
          end

          it "prefills the form with the temp_contact_postcode" do
            expect(contact_address_manual_form.postcode).to eq("foo")
          end

          it "does not prefill the form with the existing address" do
            expect(contact_address_manual_form.house_number).not_to eq(contact_address.house_number)
          end
        end
      end
    end

    describe "#submit" do
      context "when the form is valid" do
        let(:contact_address_manual_form) { build(:contact_address_manual_form, :has_required_data) }
        let(:valid_params) do
          {
            token: contact_address_manual_form.token,
            contact_address: {
              house_number: "12",
              address_line_1: "My house road",
              address_line_2: "Nothing",
              town_city: "London",
              postcode: "BS1 5AH",
              country: contact_address_manual_form.country
            }
          }
        end

        it "submits" do
          expect(contact_address_manual_form.submit(valid_params)).to be true
        end
      end

      context "when the form is not valid" do
        let(:contact_address_manual_form) { build(:contact_address_manual_form, :has_required_data) }
        let(:invalid_params) { { token: "foo" } }

        it "does not submit" do
          expect(contact_address_manual_form.submit(invalid_params)).to be false
        end
      end
    end

    context "when a valid contact address exists and is still valid" do
      let(:contact_address) { build(:address, :contact, :has_required_data) }
      let(:transient_registration) do
        build(
          :renewing_registration,
          :has_required_data,
          workflow_state: "contact_address_manual_form",
          contact_address: contact_address,
          temp_contact_postcode: contact_address.postcode
        )
      end
      # Don't use FactoryBot for this as we need to make sure it initializes with a specific object
      let(:contact_address_manual_form) { described_class.new(transient_registration) }

      context "when everything meets the requirements" do
        it "is valid" do
          expect(contact_address_manual_form).to be_valid
        end
      end

      describe "#house_number" do
        context "when the house_number is blank" do
          before do
            contact_address_manual_form.contact_address.house_number = nil
          end

          it "is not valid" do
            expect(contact_address_manual_form).not_to be_valid
          end
        end

        context "when the house_number is too long" do
          before do
            contact_address_manual_form.contact_address.house_number = "1767217672701701770041563533191862858216711534112759290091467119071305962652874388673510958015949702771617744287044629700938926040595129731732659267801150029749795917354487895716341751221579349683254601"
          end

          it "is not valid" do
            expect(contact_address_manual_form).not_to be_valid
          end
        end
      end

      describe "#address_line_1" do
        context "when the address_line_1 is blank" do
          before do
            contact_address_manual_form.contact_address.address_line_1 = nil
          end

          it "is not valid" do
            expect(contact_address_manual_form).not_to be_valid
          end
        end

        context "when the address_line_1 is too long" do
          before do
            contact_address_manual_form.contact_address.address_line_1 = "dj2mpm1gioexmhxsomk9o7oo8h5c7y7o8j2pmnwxefvoy91v9ghm7saz10r2lmdqhl3r6of58qlmlar2qeepah8c9rs8i78s2j94ws6y0gq1mxy4cw6s5myjugw62er6d2gpai0b11gsb18s2sfb9rcllye22b38o4"
          end

          it "is not valid" do
            expect(contact_address_manual_form).not_to be_valid
          end
        end
      end

      describe "#address_line_2" do
        context "when the address_line_2 is too long" do
          before do
            contact_address_manual_form.contact_address.address_line_2 = "gsm2lgu3q7cg5pcs02ftc1wtpx4lt5ghmyaclhe9qg9li7ibs5ldi3w3n1pt24pbfo0666bq"
          end

          it "is not valid" do
            expect(contact_address_manual_form).not_to be_valid
          end
        end
      end

      describe "#town_city" do
        context "when the town_city is blank" do
          before do
            contact_address_manual_form.contact_address.town_city = nil
          end

          it "is not valid" do
            expect(contact_address_manual_form).not_to be_valid
          end
        end

        context "when the town_city is too long" do
          before do
            contact_address_manual_form.contact_address.town_city = "4jhjdq46425oqers8r0b0xejkl19bapc"
          end

          it "is not valid" do
            expect(contact_address_manual_form).not_to be_valid
          end
        end
      end

      describe "#postcode" do
        context "when the postcode is too long" do
          before do
            contact_address_manual_form.contact_address.postcode = "4jhjdq46425oqers8r0b0xejkl19bapc"
          end

          it "is not valid" do
            expect(contact_address_manual_form).not_to be_valid
          end
        end
      end

      describe "#country" do
        context "when the country is blank" do
          before do
            contact_address_manual_form.contact_address.country = nil
          end

          context "when the business is not overseas" do
            before do
              contact_address_manual_form.transient_registration.location = "england"
              contact_address_manual_form.transient_registration.business_type = "limitedCompany"
            end

            it "is valid" do
              expect(contact_address_manual_form).to be_valid
            end
          end

          context "when the business is overseas" do
            before do
              contact_address_manual_form.transient_registration.location = "overseas"
              contact_address_manual_form.transient_registration.business_type = "overseas"
            end

            it "is not valid" do
              expect(contact_address_manual_form).not_to be_valid
            end
          end
        end

        context "when the country is too long" do
          before do
            contact_address_manual_form.contact_address.country = "f8x4jhjdq46425oqers8r0b0xejkl19bapc4jhjdq46425oqers"
          end

          it "is not valid" do
            expect(contact_address_manual_form).not_to be_valid
          end
        end
      end
    end
  end
end
