# frozen_string_literal: true

RSpec.shared_examples "Search scopes" do |record_class:, factory:|
  let(:non_matching_record) do
    create(factory,
           :has_required_data)
  end

  describe "#search_term" do
    let(:term) { nil }
    let(:scope) { record_class.search_term(term) }

    it "returns everything when no search term is given" do
      expect(scope.length).to eq(record_class.all.length)
    end

    context "when the search term is a reg_identifier" do
      let(:term) { "CBDU0001" }

      let(:matching_record) do
        create(factory, :has_required_data, reg_identifier: term)
      end

      it "returns records with a matching reg_identifier" do
        expect(scope).to include(matching_record)
      end

      it "does not return others" do
        expect(scope).not_to include(non_matching_record)
      end
    end

    context "when the search term is a registered_company_name" do
      let(:term) { "Absolute Skips" }

      let(:matching_record) do
        create(factory, :has_required_data, registered_company_name: "Absolute Skips Ltd")
      end

      it "returns records with a matching registered_company_name" do
        expect(scope).to include(matching_record)
      end

      it "does not return others" do
        expect(scope).not_to include(non_matching_record)
      end
    end

    context "when the search term is a name" do
      let(:term) { "Lee" }

      let(:matching_company_name_record) do
        create(factory, :has_required_data, company_name: "Stan Lee Waste Company")
      end

      let(:matching_person_name_record) do
        create(factory, :has_required_data, last_name: "Lee")
      end

      it "returns records with a matching company_name" do
        expect(scope).to include(matching_company_name_record)
      end

      it "returns records with a matching last_name" do
        expect(scope).to include(matching_person_name_record)
      end

      it "does not return others" do
        expect(scope).not_to include(non_matching_record)
      end
    end

    context "when the search term is a postcode" do
      let(:term) { "SW1A 2AA" }

      let(:matching_postcode_record) do
        address = build(:address, postcode: term)
        create(factory, :has_required_data, addresses: [address])
      end

      it "returns records with a matching postcode" do
        expect(scope).to include(matching_postcode_record)
      end

      it "does not return others" do
        expect(scope).not_to include(non_matching_record)
      end
    end

    context "when the search term has special characters" do
      let(:term) { "*" }

      it "does not break the search" do
        expect { scope }.to_not raise_error
      end
    end
  end
end
