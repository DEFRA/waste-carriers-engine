# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe RegistrationCompletionService do
    let(:registration) { create(:registration, :has_required_data, :is_pending) }

    let(:service) { RegistrationCompletionService.run(registration: registration) }

    let(:current_time) { Time.new(2020, 1, 1) }

    describe "run" do
      before { allow(Time).to receive(:current).and_return(current_time) }

      it "updates the date_activated" do
        registration.metaData.update_attributes(date_activated: nil)

        expect { service }.to change { registration.metaData.reload.date_activated }.to(current_time)
      end

      it "activates the registration" do
        expect { service }.to change { registration.active? }.from(false).to(true)
      end
    end
  end
end
