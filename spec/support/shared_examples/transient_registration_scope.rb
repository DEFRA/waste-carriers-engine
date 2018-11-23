# frozen_string_literal: true

RSpec.shared_examples "TransientRegistration named scopes" do
  let(:in_progress_renewal) do
    create(:transient_registration, :has_required_data)
  end

  let(:submitted_renewal) do
    create(:transient_registration,
           :has_required_data,
           workflow_state: :renewal_received_form)
  end

  let(:pending_payment_renewal) do
    create(:transient_registration,
           :has_required_data,
           :has_unpaid_balance,
           workflow_state: :renewal_received_form)
  end

  let(:pending_approval_renewal) do
    create(:transient_registration,
           :has_required_data,
           :requires_conviction_check,
           workflow_state: :renewal_received_form)
  end

  describe "#search_term" do
    let(:term) { nil }
    let(:scope) { WasteCarriersEngine::TransientRegistration.search_term(term) }

    it "returns everything when no search term is given" do
      expect(scope.length).to eq(WasteCarriersEngine::TransientRegistration.all.length)
    end

    context "when the search term is a reg_identifier" do
      let(:term) { in_progress_renewal.reg_identifier }

      it "returns only the matching renewal" do
        expect(scope).to include(in_progress_renewal)
        expect(scope.length).to eq(1)
      end
    end

    context "when the search term is a name" do
      let(:matching_company_name_renewal) do
        create(:transient_registration, :has_required_data, company_name: "Stan Lee Waste Company")
      end

      let(:matching_person_name_renewal) do
        create(:transient_registration, :has_required_data, last_name: "Lee")
      end

      let(:term) { "Lee" }

      it "returns all matching renewals" do
        expect(scope).to include(matching_company_name_renewal)
        expect(scope).to include(matching_person_name_renewal)
        expect(scope).not_to include(in_progress_renewal)
      end
    end

    context "when a postcode search term is given" do
      let(:matching_postcode_renewal) do
        address = build(:address, postcode: "SW1A 2AA")
        create(:transient_registration, :has_required_data, addresses: [address])
      end

      let(:non_matching_postcode_renewal) do
        address = build(:address, postcode: "BS1 5AH")
        create(:transient_registration, :has_required_data, addresses: [address])
      end

      let(:term) { matching_postcode_renewal.addresses.first.postcode }

      it "returns all matching renewals when a postcode is given" do
        expect(scope).to include(matching_postcode_renewal)
        expect(scope).not_to include(non_matching_postcode_renewal)
      end
    end
  end

  describe "#in_progress" do
    let(:scope) { WasteCarriersEngine::TransientRegistration.in_progress }

    it "returns in progress renewals when they exist" do
      expect(scope).to include(in_progress_renewal)
    end

    it "does not return submitted renewals" do
      expect(scope).not_to include(submitted_renewal)
    end
  end

  describe "#submitted" do
    let(:scope) { WasteCarriersEngine::TransientRegistration.submitted }

    it "returns submitted renewals" do
      expect(scope).to include(submitted_renewal)
    end

    it "does not return in progress renewals" do
      expect(scope).not_to include(in_progress_renewal)
    end
  end

  describe "#pending_payment" do
    let(:scope) { WasteCarriersEngine::TransientRegistration.pending_payment }

    it "returns renewals pending payment" do
      expect(scope).to include(pending_payment_renewal)
    end

    it "does not return others" do
      expect(scope).not_to include(in_progress_renewal)
    end
  end

  describe "#pending_approval" do
    let(:scope) { WasteCarriersEngine::TransientRegistration.pending_approval }

    it "returns renewals pending conviction approval" do
      expect(scope).to include(pending_approval_renewal)
    end

    it "does not return others" do
      expect(scope).not_to include(in_progress_renewal)
    end
  end
end
