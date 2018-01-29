VCR.configure do |c|
  c.cassette_library_dir = "spec/cassettes"
  c.hook_into :webmock

  c.ignore_hosts "127.0.0.1", "codeclimate.com"

  c.default_cassette_options = { re_record_interval: 14.days }

  # Strip out authorization info
  c.filter_sensitive_data("Basic <COMPANIES_HOUSE_API_KEY>") do |interaction|
    interaction.request.headers["Authorization"].first
  end
end
