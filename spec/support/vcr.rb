# frozen_string_literal: true

VCR.configure do |c|
  c.cassette_library_dir = "spec/cassettes"
  c.hook_into :webmock

  c.ignore_hosts "127.0.0.1", "codeclimate.com"

  c.default_cassette_options = { re_record_interval: 14.days }

  # Strip out authorization info
  c.filter_sensitive_data("Basic <API_KEY>") do |interaction|
    interaction.request.headers["Authorization"].first if interaction.request.headers["Authorization"].present?
  end

  c.filter_sensitive_data("MERCHANT_CODE") { Rails.configuration.worldpay_merchantcode }
end
