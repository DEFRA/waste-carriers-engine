# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe WasteCarriersEngine::DataLayerHelper, type: :helper do
    describe "data_layer" do
      let(:transient_registration) { double(:transient_registration) }

      before do
        expect(transient_registration).to receive_message_chain(:class, :name).and_return(class_double)
      end

      context "when the transient_registration is a CeasedOrRevokedRegistration" do
        let(:class_double) { "WasteCarriersEngine::CeasedOrRevokedRegistration" }
        it "returns the correct value" do
          expected_string = "'journey': 'cease_or_revoke'"

          expect(helper.data_layer(transient_registration)).to eq(expected_string)
        end
      end

      context "when the transient_registration is an EditRegistration" do
        let(:class_double) { "WasteCarriersEngine::EditRegistration" }
        it "returns the correct value" do
          expected_string = "'journey': 'edit'"

          expect(helper.data_layer(transient_registration)).to eq(expected_string)
        end
      end

      context "when the transient_registration is a NewRegistration" do
        let(:class_double) { "WasteCarriersEngine::NewRegistration" }
        it "returns the correct value" do
          expected_string = "'journey': 'new'"

          expect(helper.data_layer(transient_registration)).to eq(expected_string)
        end
      end

      context "when the transient_registration is an OrderCopyCardsRegistration" do
        let(:class_double) { "WasteCarriersEngine::OrderCopyCardsRegistration" }
        it "returns the correct value" do
          expected_string = "'journey': 'order_copy_cards'"

          expect(helper.data_layer(transient_registration)).to eq(expected_string)
        end
      end

      context "when the transient_registration is a RenewingRegistration" do
        let(:class_double) { "WasteCarriersEngine::RenewingRegistration" }
        it "returns the correct value" do
          expected_string = "'journey': 'renew'"

          expect(helper.data_layer(transient_registration)).to eq(expected_string)
        end
      end

      context "when the transient_registration is not a recognised subtype" do
        let(:class_double) { "Foo" }
        it "raises an error" do
          expect { helper.data_layer(transient_registration) }.to raise_error(DataLayerHelper::UnexpectedSubtypeError)
        end
      end
    end
  end
end
