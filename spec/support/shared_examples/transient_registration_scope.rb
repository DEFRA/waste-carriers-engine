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

    it "returns all matching renewals when a postcode is given" do
      ["SW1A 2AA", "BS1 5AH"].each do |postcode|
        address = build(:address, postcode: postcode)
        create(:transient_registration, :has_required_data, addresses: [address])
      end

      results = WasteCarriersEngine::TransientRegistration.search_term("SW1A 2AA")

      expect(results.first.addresses[0].postcode).to eq("SW1A 2AA")
      expect(results.length).to eq(1)
    end
  end

  describe "#in_progress" do
    it "returns in progress renewals when they exist" do
      expect(WasteCarriersEngine::TransientRegistration.in_progress).to include(in_progress_renewal)
    end

    it "does not return submitted renewals" do
      expect(WasteCarriersEngine::TransientRegistration.in_progress).not_to include(submitted_renewal)
    end
  end

  describe "#submitted" do
    it "returns submitted renewals" do
      expect(WasteCarriersEngine::TransientRegistration.submitted).to include(submitted_renewal)
    end

    it "does not return in progress renewals" do
      expect(WasteCarriersEngine::TransientRegistration.submitted).not_to include(in_progress_renewal)
    end
  end

  describe "#pending_payment" do
    it "returns renewals pending payment" do
      expect(WasteCarriersEngine::TransientRegistration.pending_payment).to include(pending_payment_renewal)
    end

    it "does not return others" do
      expect(WasteCarriersEngine::TransientRegistration.pending_payment).not_to include(in_progress_renewal)
    end
  end

  describe "#pending_approval" do
    it "returns renewals pending conviction approval" do
      expect(WasteCarriersEngine::TransientRegistration.pending_approval).to include(pending_approval_renewal)
    end

    it "does not return others" do
      expect(WasteCarriersEngine::TransientRegistration.pending_approval).not_to include(in_progress_renewal)
    end
  end
end
