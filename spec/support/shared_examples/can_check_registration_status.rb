# frozen_string_literal: true

RSpec.shared_examples "Can check registration status" do |factory:|
  let(:resource) { build(factory, :has_required_data) }

  describe "#status" do
    before { resource.metaData.status = "ACTIVE" }

    it "outputs a lowercase symbol of the metadata status" do
      expect(resource.status).to eq(:active)
    end
  end

  describe "#active?" do
    context "when the metadata status is active" do
      before { resource.metaData.status = "ACTIVE" }

      it "returns true" do
        expect(resource).to be_active
      end
    end

    context "when the metadata status is not active" do
      before { resource.metaData.status = "PENDING" }

      it "returns false" do
        expect(resource).to_not be_active
      end
    end
  end

  describe "#expired?" do
    context "when the metadata status is expired" do
      before { resource.metaData.status = "EXPIRED" }

      it "returns true" do
        expect(resource).to be_expired
      end
    end

    context "when the metadata status is not expired" do
      before { resource.metaData.status = "ACTIVE" }

      it "returns false" do
        expect(resource).to_not be_expired
      end
    end
  end

  describe "#inactive?" do
    context "when the metadata status is inactive" do
      before { resource.metaData.status = "INACTIVE" }

      it "returns true" do
        expect(resource).to be_inactive
      end
    end

    context "when the metadata status is not inactive" do
      before { resource.metaData.status = "ACTIVE" }

      it "returns false" do
        expect(resource).to_not be_inactive
      end
    end
  end

  describe "#pending?" do
    context "when the metadata status is pending" do
      before { resource.metaData.status = "PENDING" }

      it "returns true" do
        expect(resource).to be_pending
      end
    end

    context "when the metadata status is not pending" do
      before { resource.metaData.status = "ACTIVE" }

      it "returns false" do
        expect(resource).to_not be_pending
      end
    end
  end

  describe "#refused?" do
    context "when the metadata status is refused" do
      before { resource.metaData.status = "REFUSED" }

      it "returns true" do
        expect(resource).to be_refused
      end
    end

    context "when the metadata status is not refused" do
      before { resource.metaData.status = "ACTIVE" }

      it "returns false" do
        expect(resource).to_not be_refused
      end
    end
  end

  describe "#revoked?" do
    context "when the metadata status is revoked" do
      before { resource.metaData.status = "REVOKED" }

      it "returns true" do
        expect(resource).to be_revoked
      end
    end

    context "when the metadata status is not revoked" do
      before { resource.metaData.status = "ACTIVE" }

      it "returns false" do
        expect(resource).to_not be_revoked
      end
    end
  end
end
