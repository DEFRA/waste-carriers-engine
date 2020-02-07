# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe EditRegistration, type: :model do
    subject(:edit_registration) { build(:edit_registration) }

    context "default status" do
      context "when an EditRegistration is created" do
        it "has the state of :edit_form" do
          expect(edit_registration).to have_state(:edit_form)
        end
      end
    end

    context "Validations" do
      describe "reg_identifier" do
        context "when an EditRegistration is created" do
          it "is not valid if the reg_identifier is in the wrong format" do
            edit_registration.reg_identifier = "foo"
            expect(edit_registration).to_not be_valid
          end

          it "is not valid if no matching registration exists" do
            edit_registration.reg_identifier = "CBDU999999"
            expect(edit_registration).to_not be_valid
          end
        end
      end
    end
  end
end
