# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe SafeCopyAttributesService do
    describe "#run" do
      subject(:run_service) { described_class.run(source_instance:, target_class:, embedded_documents:, attributes_to_exclude:) }

      let(:embedded_documents) { [] }
      let(:attributes_to_exclude) { [] }

      before do
        unless source_instance.is_a?(BSON::Document) || source_instance.is_a?(Hash)
          source_instance.class.fields.keys.excluding("_id").each do |attr|
            next unless source_instance.send(attr).blank? && source_instance.respond_to?("#{attr}=")
            source_instance.send "#{attr}=", 0
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

        context "with an exclusion list" do
          let(:attributes_to_exclude) { exclusion_list }

          it "does not return the excluded attributes" do
            expect(run_service.keys).not_to include(*exclusion_list)
          end
        end
      end

      context "when the target is a Registration" do
        let(:target_class) { Registration }
        let(:embedded_documents) { %w[addresses financeDetails metaData] }
        let(:copyable_attributes) { %w[location contactEmail] }
        let(:non_copyable_attributes) { %w[workflow_state temp_contact_postcode not_even_an_attribute] }
        let(:exclusion_list) { %w[_id email_history] }


        context "when the source is a Hash with attributes not in the model" do
          let(:source_instance) do
            {
              "location" => "uk",
              "contactEmail" => "test@example.com",
              "deprecated_attribute" => "some value",
              "another_non_existent_attr" => 123
            }
          end

          it "copies only the attributes that exist in the model" do
            result = run_service
            expect(result["location"]).to eq("uk")
            expect(result["contactEmail"]).to eq("test@example.com")
            expect(result).not_to have_key("deprecated_attribute")
            expect(result).not_to have_key("another_non_existent_attr")
          end
        end

        context "when the source is a BSON::Document with attributes not in the model" do
          let(:source_instance) do
            BSON::Document.new(
              "location" => "uk",
              "contactEmail" => "test@example.com",
              "deprecated_attribute" => "some value",
              "another_non_existent_attr" => 123
            )
          end

          it "copies only the attributes that exist in the model" do
            result = run_service
            expect(result["location"]).to eq("uk")
            expect(result["contactEmail"]).to eq("test@example.com")
            expect(result).not_to have_key("deprecated_attribute")
            expect(result).not_to have_key("another_non_existent_attr")
          end
        end


        context "when the source is a NewRegistration" do
          let(:source_instance) { build(:new_registration, :has_required_data) }
          it_behaves_like "returns the correct attributes"
        end

        context "when the source is a RenewingRegistration" do
          let(:source_instance) { build(:renewing_registration, :has_required_data) }
          it_behaves_like "returns the correct attributes"
        end

        context "when the source is a DeregisteringRegistration" do
          let(:source_instance) { build(:deregistering_registration, location: "uk", contact_email: 'any@email.com') }
          it_behaves_like "returns the correct attributes"
        end

        context "when the source is a BSON::Document" do
          let(:source_instance) { BSON::Document.new(build(:new_registration, :has_required_data).attributes) }
          it_behaves_like "returns the correct attributes"
        end

        context "with embedded documents" do
          let(:source_instance) { build(:new_registration, :has_required_data, :has_addresses, :has_paid_finance_details) }

          it "correctly copies embedded documents" do
            result = run_service
            expect(result["addresses"]).to be_an(Array)
            expect(result["addresses"].first).to include("postcode", "houseNumber")
            expect(result["finance_details"]).to include("balance")
          end
        end
      end

      context "when the source and target are Addresses" do
        let(:source_instance) { build(:address, :has_required_data) }
        let(:target_class) { Address }
        let(:copyable_attributes) { %w[postcode houseNumber] }
        let(:non_copyable_attributes) { %w[not_an_attribute neitherIsThis] }
        let(:exclusion_list) { %w[_id royalMailUpdateDate localAuthorityUpdateDate] }

        it_behaves_like "returns the correct attributes"
      end

      context "when the source and target are KeyPersons" do
        let(:source_instance) { build(:key_person, :has_required_data) }
        let(:target_class) { KeyPerson }
        let(:copyable_attributes) { %w[first_name dob] }
        let(:non_copyable_attributes) { %w[not_an_attribute neitherIsThis] }
        let(:exclusion_list) { %w[_id position] }

        it_behaves_like "returns the correct attributes"
      end
    end
  end
end
