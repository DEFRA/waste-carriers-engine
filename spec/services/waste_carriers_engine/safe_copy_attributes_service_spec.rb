# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe SafeCopyAttributesService do
    describe "#run" do

      subject(:run_service) { described_class.run(source_instance:, target_class:, embedded_documents:, attributes_to_exclude:) }

      let(:embedded_documents) { nil }
      let(:exclusion_list) { nil }
      let(:attributes_to_exclude) { exclusion_list }

      # ensure all available attributes are populated on the source
      before do
        source_instance.class.fields.keys.excluding("_id").each do |attr|
          next unless source_instance.send(attr).blank? && source_instance.respond_to?("#{attr}=")

          source_instance.send "#{attr}=", 0
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

          it "does not return the excluded attibutes" do
            expect(run_service.keys).not_to include(exclusion_list)
          end
        end
      end

      context "when the target is a Registration" do
        let(:target_class) { Registration }
        # include all embeds_many relationships
        let(:embedded_documents) { %w[addresses finainceDetails metaData] }
        let(:copyable_attributes) { %w[location contactEmail] }
        let(:non_copyable_attributes) { %w[workflow_state temp_contact_postcode not_even_an_attribute] }
        let(:exclusion_list) { %w[_id email_history] }

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
