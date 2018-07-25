# frozen_string_literal: true

require "rails_helper"
require "waste_carriers_engine/secret_key_checker"

RSpec.describe "SecretKeyChecker" do

  describe "#valid?" do

    context "when the secret key is valid" do
      it "confirms the key is valid" do
        expect(WasteCarriersEngine::SecretKeyChecker.new("71ea996f1ac55f87a94b50feb9fab21ca967c76d").valid?).to be true
      end
    end

    context "when the secret key is null" do
      it "confirms the key is invalid" do
        expect(WasteCarriersEngine::SecretKeyChecker.new(nil).valid?).to be false
      end
    end

    context "when the secret key is empty" do
      it "confirms the key is invalid" do
        expect(WasteCarriersEngine::SecretKeyChecker.new("").valid?).to be false
      end
    end

    context "when the secret key is set to the production default" do
      it "confirms the key is invalid" do
        expect(WasteCarriersEngine::SecretKeyChecker.new("iamonlyherefordeviseduringassetcompilation").valid?).to be false
      end
    end

  end

  describe "#abort_if_invalid" do
    context "when the secret key is valid" do
      it "does not abort" do
        expect { WasteCarriersEngine::SecretKeyChecker.new("71ea996f1ac55f87a94b50feb9fab21ca967c76d").abort_if_invalid }.not_to raise_error
      end
    end
    context "when the secret key is invalid" do
      it "aborts" do
        # This is here just to stop the abort message appearing in our rspec
        # output and messing up its formatting.
        allow($stderr).to receive(:write) { "" }

        expect { WasteCarriersEngine::SecretKeyChecker.new("").abort_if_invalid }.to raise_error(SystemExit)
      end
    end
  end

end
