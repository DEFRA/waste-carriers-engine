# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "RenewalReceivedPendingPaymentForms", type: :request do
    include_examples "GET locked-in form", "renewal_received_pending_payment_form"
  end
end
