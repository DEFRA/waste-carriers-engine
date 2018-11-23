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

      it "returns renewals with a matching reg_identifier" do
        expect(scope).to include(in_progress_renewal)
      end

      it "does not return others" do
        expect(scope).not_to include(submitted_renewal)
      end
    end

    context "when the search term is a name" do
      let(:term) { "Lee" }

      let(:matching_company_name_renewal) do
        create(:transient_registration, :has_required_data, company_name: "Stan Lee Waste Company")
      end

      let(:matching_person_name_renewal) do
        create(:transient_registration, :has_required_data, last_name: "Lee")
      end

      it "returns renewals with a matching company_name" do
        expect(scope).to include(matching_company_name_renewal)
      end

      it "returns renewals with a matching last_name" do
        expect(scope).to include(matching_person_name_renewal)
      end

      it "does not return others" do
        expect(scope).not_to include(in_progress_renewal)
      end
    end

    context "when the search term is a postcode" do
      let(:term) { "SW1A 2AA" }

      let(:matching_postcode_renewal) do
        address = build(:address, postcode: term)
        create(:transient_registration, :has_required_data, addresses: [address])
      end

      it "returns renewals with a matching postcode" do
        expect(scope).to include(matching_postcode_renewal)
      end

      it "does not return others" do
        expect(scope).not_to include(in_progress_renewal)
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
