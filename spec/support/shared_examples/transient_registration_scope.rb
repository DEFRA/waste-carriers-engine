# frozen_string_literal: true

RSpec.shared_examples "TransientRegistration named scopes" do
  context "#search_term" do
    it "returns everything when no search term is given" do
      expect(WasteCarriersEngine::TransientRegistration.search_term(nil).length).to eq(WasteCarriersEngine::TransientRegistration.all.length)
    end

    it "returns only matching renewal when a reg. identifier is given" do
      matching_renewal = create(:transient_registration, :has_required_data)
      create(:transient_registration, :has_required_data)
      results = WasteCarriersEngine::TransientRegistration.search_term(
        matching_renewal.reg_identifier
      )

      expect(results).to include(matching_renewal)
      expect(results.length).to eq(1)
    end

    it "returns all matching renewals when a general name is given" do
      create(:transient_registration, :has_required_data, company_name: "Stan Lee Waste Company")
      create(:transient_registration, :has_required_data, last_name: "Lee")
      non_matching_renewal = create(:transient_registration, :has_required_data, company_name: "Excelsior Waste")
      results = WasteCarriersEngine::TransientRegistration.search_term("lee")

      expect(results).not_to include(non_matching_renewal)
      expect(results.length).to eq(2)
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

  context "#in_progress" do
    it "returns in progress renewals when they exist" do
      in_progress_renewal = create(:transient_registration, :has_required_data)
      expect(WasteCarriersEngine::TransientRegistration.in_progress).to include(in_progress_renewal)
    end

    it "does not return submitted renewals" do
      submitted_renewal = create(
        :transient_registration,
        :has_required_data,
        workflow_state: :renewal_complete_form
      )
      expect(WasteCarriersEngine::TransientRegistration.in_progress).not_to include(submitted_renewal)
    end
  end

  context "#submitted" do
    it "returns submitted renewals" do
      submitted_renewal = create(
        :transient_registration,
        :has_required_data,
        workflow_state: :renewal_complete_form
      )
      expect(WasteCarriersEngine::TransientRegistration.submitted).to include(submitted_renewal)
    end

    it "does not return in progress renewals" do
      in_progress_renewal = create(:transient_registration, :has_required_data)
      expect(WasteCarriersEngine::TransientRegistration.submitted).not_to include(in_progress_renewal)
    end
  end

  context "#pending_payment" do
    it "returns renewals pending payment" do
      pending_payment_renewal = create(
        :transient_registration,
        :has_required_data,
        :has_unpaid_balance,
        workflow_state: :renewal_complete_form
      )
      expect(WasteCarriersEngine::TransientRegistration.pending_payment).to include(pending_payment_renewal)
    end

    it "does not return others" do
      in_progress_renewal = create(:transient_registration, :has_required_data)
      expect(WasteCarriersEngine::TransientRegistration.pending_payment).not_to include(in_progress_renewal)
    end
  end

  context "#pending_approval" do
    it "returns renewals pending conviction approval" do
      pending_approval_renewal = create(
        :transient_registration,
        :has_required_data,
        :requires_conviction_check,
        workflow_state: :renewal_complete_form
      )
      expect(WasteCarriersEngine::TransientRegistration.pending_approval).to include(pending_approval_renewal)
    end

    it "does not return others" do
      in_progress_renewal = create(:transient_registration, :has_required_data)
      expect(WasteCarriersEngine::TransientRegistration.pending_approval).not_to include(in_progress_renewal)
    end
  end

  describe "conviction check scopes" do
    let(:convictions_renewal) do
      create(
        :transient_registration,
        :has_required_data,
        :requires_conviction_check,
        workflow_state: :renewal_received_form
      )
    end

    let(:convictions_possible_match_renewal) do
      convictions_renewal
    end

    let(:convictions_checks_in_progress_renewal) do
      convictions_renewal.conviction_sign_offs.first.begin_checks!
      convictions_renewal
    end

    let(:convictions_approved_renewal) do
      convictions_renewal.conviction_sign_offs.first.approve!(build(:user))
      convictions_renewal
    end

    let(:convictions_rejected_renewal) do
      convictions_renewal.conviction_sign_offs.first.reject!
      convictions_renewal
    end

    describe "#convictions_possible_match" do
      let(:scope) { WasteCarriersEngine::TransientRegistration.convictions_possible_match }

      it "returns renewals where a conviction_sign_off is in the possible_match state" do
        expect(scope).to include(convictions_possible_match_renewal)
      end

      it "does not return others" do
        expect(scope).not_to include(convictions_checks_in_progress_renewal)
      end
    end

    describe "#convictions_checks_in_progress" do
      let(:scope) { WasteCarriersEngine::TransientRegistration.convictions_checks_in_progress }

      it "returns renewals where a conviction_sign_off is in the checks_in_progress state" do
        expect(scope).to include(convictions_checks_in_progress_renewal)
      end

      it "does not return others" do
        expect(scope).not_to include(convictions_possible_match_renewal)
      end
    end

    describe "#convictions_approved" do
      let(:scope) { WasteCarriersEngine::TransientRegistration.convictions_approved }

      it "returns renewals where a conviction_sign_off is in the approved state" do
        expect(scope).to include(convictions_approved_renewal)
      end

      it "does not return others" do
        expect(scope).not_to include(convictions_possible_match_renewal)
      end
    end

    describe "#convictions_rejected" do
      let(:scope) { WasteCarriersEngine::TransientRegistration.convictions_rejected }

      it "returns renewals where a conviction_sign_off is in the rejected state" do
        expect(scope).to include(convictions_rejected_renewal)
      end

      it "does not return others" do
        expect(scope).not_to include(convictions_possible_match_renewal)
      end
    end
  end
end
