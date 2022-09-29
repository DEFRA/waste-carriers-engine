# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe PermissionChecksResult do
    subject(:result) { described_class.new }

    describe "#pass!" do
      it "set the @pass instance variable to true" do
        expect { result.pass! }.to change { result.instance_variable_get("@pass") }.to(true)
      end
    end

    describe "#pass?" do
      it "returns the value of the pass instance variable" do
        result.instance_variable_set("@pass", "foo")

        expect(result.pass?).to eq("foo")
      end
    end

    describe "#needs_permissions!" do
      it "set the @error_state instance variable to permission" do
        expect { result.needs_permissions! }.to change(result, :error_state).to("permission")
      end
    end

    describe "#unrenewable!" do
      it "set the @error_state instance variable to unrenewable" do
        expect { result.unrenewable! }.to change(result, :error_state).to("unrenewable")
      end
    end

    describe "#invalid!" do
      it "set the @error_state instance variable to invalid" do
        expect { result.invalid! }.to change(result, :error_state).to("invalid")
      end
    end
  end
end
