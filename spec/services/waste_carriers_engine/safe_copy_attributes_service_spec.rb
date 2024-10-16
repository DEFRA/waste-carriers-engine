# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe SafeCopyAttributesService do
    describe "#run" do
      subject(:run_service) do
        described_class.run(
          source_instance: source_instance,
          target_class: target_class
        )
      end

      # Ensure all available attributes are populated on the source
      before do
        unless source_instance.is_a?(BSON::Document)
          source_instance.class.fields.keys.excluding("_id").each do |attr|
            next unless source_instance.send(attr).blank? && source_instance.respond_to?("#{attr}=")

            source_instance.send("#{attr}=", 0)
          end
        end
      end

      shared_examples "returns the correct attributes" do
        it { expect { run_service }.not_to raise_error }

        it "returns copyable attributes" do
          result = run_service
          copyable_attributes.each { |attr| expect(result[attr]).not_to be_nil }
        end

        it "does not return non-copyable attributes" do
          result = run_service
          non_copyable_attributes.each { |attr| expect(result[attr]).to be_nil }
        end
      end

      context "when the target is a Registration" do
        let(:target_class) { Registration }
        let(:copyable_attributes) { %w[location contactEmail] }
        let(:non_copyable_attributes) { %w[workflow_state temp_contact_postcode not_even_an_attribute _id email_history] }

        context "when the source is a NewRegistration" do
          let(:source_instance) { build(:new_registration, :has_required_data) }

          it_behaves_like "returns the correct attributes"
        end

        context "when the source is a RenewingRegistration" do
          let(:source_instance) { build(:renewing_registration, :has_required_data) }

          it_behaves_like "returns the correct attributes"
        end

        context "when the source is a DeregisteringRegistration" do
          let(:source_instance) { build(:deregistering_registration) }

          it_behaves_like "returns the correct attributes"
        end

        context "when the source is a BSON::Document" do
          let(:source_instance) do
            attributes = build(:new_registration, :has_required_data).attributes
            attributes["non_existent_attribute"] = "some value"
            BSON::Document.new(attributes)
          end

          # Include the non-existent attribute in non_copyable_attributes
          let(:non_copyable_attributes) { super() + ["non_existent_attribute"] }

          it_behaves_like "returns the correct attributes"
        end
      end

      context "when the source and target are Addresses" do
        let(:source_instance) { build(:address, :has_required_data) }
        let(:target_class) { Address }
        let(:copyable_attributes) { %w[postcode houseNumber] }
        let(:non_copyable_attributes) { %w[not_an_attribute neitherIsThis _id royalMailUpdateDate localAuthorityUpdateDate] }

        it_behaves_like "returns the correct attributes"
      end

      context "when the source and target are KeyPersons" do
        let(:source_instance) { build(:key_person, :has_required_data) }
        let(:target_class) { KeyPerson }
        let(:copyable_attributes) { %w[first_name dob] }
        let(:non_copyable_attributes) { %w[not_an_attribute neitherIsThis _id position] }

        it_behaves_like "returns the correct attributes"
      end

      context "when the source is a BSON::Document with an attribute not present on the model" do
        let(:target_class) { Registration }
        let(:source_instance) do
          attributes = {
            "location" => "uk",
            "contactEmail" => "test@example.com",
            "non_existent_attribute" => "some value"
          }
          BSON::Document.new(attributes)
        end

        let(:copyable_attributes) { %w[location contactEmail] }
        let(:non_copyable_attributes) { %w[non_existent_attribute _id] }

        it_behaves_like "returns the correct attributes"
      end
    end
  end
end
