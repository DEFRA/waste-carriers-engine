# frozen_string_literal: true

RSpec.shared_examples "Can filter conviction status" do
  let(:possible_match) do
    record = described_class.new(
      conviction_sign_offs: [
        WasteCarriersEngine::ConvictionSignOff.new(workflow_state: :possible_match)
      ]
    )
    # Skip the validation so we don't have to include addresses, etc
    record.save(validate: false)
    record
  end

  let(:checks_in_progress) do
    record = described_class.new(
      conviction_sign_offs: [
        WasteCarriersEngine::ConvictionSignOff.new(workflow_state: :checks_in_progress)
      ]
    )
    # Skip the validation so we don't have to include addresses, etc
    record.save(validate: false)
    record
  end

  let(:approved) do
    record = described_class.new(
      conviction_sign_offs: [
        WasteCarriersEngine::ConvictionSignOff.new(workflow_state: :approved)
      ]
    )
    # Skip the validation so we don't have to include addresses, etc
    record.save(validate: false)
    record
  end

  let(:rejected) do
    record = described_class.new(
      conviction_sign_offs: [
        WasteCarriersEngine::ConvictionSignOff.new(workflow_state: :rejected)
      ]
    )
    # Skip the validation so we don't have to include addresses, etc
    record.save(validate: false)
    record
  end

  let(:old_confirmed_record) do
    record = described_class.new(
      conviction_sign_offs: [
        WasteCarriersEngine::ConvictionSignOff.new(confirmed: "yes")
      ]
    )
    # Skip the validation so we don't have to include addresses, etc
    record.save(validate: false)
    record
  end

  let(:no_status_pending) do
    record = described_class.new(
      conviction_sign_offs: [
        WasteCarriersEngine::ConvictionSignOff.new
      ],
      metaData: { status: "PENDING" }
    )
    # Skip the validation so we don't have to include addresses, etc
    record.save(validate: false)
    record.conviction_sign_offs.first.unset(:workflow_state)
    record
  end

  let(:no_status_active) do
    record = described_class.new(
      conviction_sign_offs: [
        WasteCarriersEngine::ConvictionSignOff.new
      ],
      metaData: { status: "ACTIVE" }
    )
    # Skip the validation so we don't have to include addresses, etc
    record.save(validate: false)
    record.conviction_sign_offs.first.unset(:workflow_state)
    record
  end

  let(:no_status_approved) do
    record = described_class.new(
      conviction_sign_offs: [
        WasteCarriersEngine::ConvictionSignOff.new(confirmed: "yes")
      ]
    )
    # Skip the validation so we don't have to include addresses, etc
    record.save(validate: false)
    record.conviction_sign_offs.first.unset(:workflow_state)
    record
  end

  describe "convictions_possible_match" do
    let(:scope) { described_class.convictions_possible_match }

    it "only returns results with the correct status" do
      expect(scope).to include(possible_match)
      expect(scope).not_to include(checks_in_progress)
      expect(scope).not_to include(approved)
      expect(scope).not_to include(rejected)
      expect(scope).not_to include(old_confirmed_record)
      expect(scope).not_to include(no_status_pending)
      expect(scope).not_to include(no_status_active)
      expect(scope).not_to include(no_status_approved)
    end
  end

  describe "convictions_checks_in_progress" do
    let(:scope) { described_class.convictions_checks_in_progress }

    it "only returns results with the correct status" do
      expect(scope).not_to include(possible_match)
      expect(scope).to include(checks_in_progress)
      expect(scope).not_to include(approved)
      expect(scope).not_to include(rejected)
      expect(scope).not_to include(old_confirmed_record)
      expect(scope).not_to include(no_status_pending)
      expect(scope).not_to include(no_status_active)
      expect(scope).not_to include(no_status_approved)
    end
  end

  describe "convictions_approved" do
    let(:scope) { described_class.convictions_approved }

    it "only returns results with the correct status" do
      expect(scope).not_to include(possible_match)
      expect(scope).not_to include(checks_in_progress)
      expect(scope).to include(approved)
      expect(scope).not_to include(rejected)
      expect(scope).not_to include(old_confirmed_record)
      expect(scope).not_to include(no_status_pending)
      expect(scope).not_to include(no_status_active)
      expect(scope).not_to include(no_status_approved)
    end
  end

  describe "convictions_rejected" do
    let(:scope) { described_class.convictions_rejected }

    it "only returns results with the correct status" do
      expect(scope).not_to include(possible_match)
      expect(scope).not_to include(checks_in_progress)
      expect(scope).not_to include(approved)
      expect(scope).to include(rejected)
      expect(scope).not_to include(old_confirmed_record)
      expect(scope).not_to include(no_status_pending)
      expect(scope).not_to include(no_status_active)
      expect(scope).not_to include(no_status_approved)
    end
  end

  describe "convictions_new_without_status" do
    let(:scope) { described_class.convictions_new_without_status }

    it "only returns results with the correct status" do
      expect(scope).not_to include(possible_match)
      expect(scope).not_to include(checks_in_progress)
      expect(scope).not_to include(approved)
      expect(scope).not_to include(rejected)
      expect(scope).not_to include(old_confirmed_record)
      expect(scope).to include(no_status_pending)
      expect(scope).not_to include(no_status_active)
      expect(scope).not_to include(no_status_approved)
    end
  end
end
