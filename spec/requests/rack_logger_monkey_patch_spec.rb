# frozen_string_literal: true

require "rails_helper"

RSpec.describe RackLoggerMonkeyPatch do
  describe "#info" do
    let(:log_file_path) { Rails.root.join("tmp/foo.log") }
    let(:log_contents) { File.read(log_file_path) }

    before { Rails.logger = ActiveSupport::Logger.new(log_file_path) }

    after { FileUtils.rm_f(log_file_path) }

    context "with a non-heartbeat route" do
      before { get "/start" }

      it { expect(log_contents).to match(/Started GET /) }
    end

    context "with the heartbeat route" do
      before { get Rails.application.config.wcrs_logger_heartbeat_path }

      it { expect(log_contents).not_to match(/Started GET /) }
    end

    context "when the 'disable_rack_logger_filter' feature-toggle is active" do
      before do
        allow(WasteCarriersEngine::FeatureToggle).to receive(:active?).with(:disable_rack_logger_filter).and_return true

        get Rails.application.config.wcrs_logger_heartbeat_path
      end

      it { expect(log_contents).to match(/Started GET /) }
    end
  end
end
