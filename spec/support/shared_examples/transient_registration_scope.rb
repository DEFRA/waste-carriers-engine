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
    it "returns everything when no search term is given" do
      expect(WasteCarriersEngine::TransientRegistration.search_term(nil).length).to eq(WasteCarriersEngine::TransientRegistration.all.length)
    end

    it "returns only matching renewal when a reg. identifier is given" do
      results = WasteCarriersEngine::TransientRegistration.search_term(
        in_progress_renewal.reg_identifier
      )

      expect(results).to include(in_progress_renewal)
      expect(results.length).to eq(1)
    end

    context "when a search term is given" do
      let(:matching_company_name_renewal) do
        create(:transient_registration, :has_required_data, company_name: "Stan Lee Waste Company")
      end

      let(:matching_person_name_renewal) do
        create(:transient_registration, :has_required_data, last_name: "Lee")
      end

      it "returns all matching renewals" do
        results = WasteCarriersEngine::TransientRegistration.search_term("lee")

        expect(results).to include(matching_company_name_renewal)
        expect(results).to include(matching_person_name_renewal)
        expect(results).not_to include(in_progress_renewal)
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

      it "returns all matching renewals when a postcode is given" do
        results = WasteCarriersEngine::TransientRegistration.search_term(
          matching_postcode_renewal.addresses.first.postcode
        )

        expect(results).to include(matching_postcode_renewal)
        expect(results).not_to include(non_matching_postcode_renewal)
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
