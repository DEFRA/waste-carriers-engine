# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe PermissionChecksResult do
    subject { described_class.new }

    describe "#pass!" do
      it "set the @pass instance variable to true" do
        expect { subject.pass! }.to change { subject.instance_variable_get("@pass") }.to(true)
      end
    end

    describe "#pass?" do
      it "returns the value of the pass instance variable" do
        subject.instance_variable_set("@pass", "foo")

        expect(subject.pass?).to eq("foo")
      end
    end

    describe "#needs_permissions!" do
      it "set the @error_state instance variable to permission" do
        expect { subject.needs_permissions! }.to change { subject.error_state }.to("permission")
      end
    end

    describe "#unrenewable!" do
      it "set the @error_state instance variable to unrenewable" do
        expect { subject.unrenewable! }.to change { subject.error_state }.to("unrenewable")
      end
    end

    describe "#invalid!" do
      it "set the @error_state instance variable to invalid" do
        expect { subject.invalid! }.to change { subject.error_state }.to("invalid")
      end
    end
  end
end
