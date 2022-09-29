# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe Govpay::Error do
    subject(:error) { described_class.new({}) }

    # this is just for coverage for now
    it { expect { error }.not_to raise_error }
  end
end
