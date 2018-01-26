VCR.configure do |c|
  c.cassette_library_dir = "spec/cassettes"
  c.hook_into :webmock

  c.ignore_hosts "127.0.0.1", "codeclimate.com"
  # Strip out authorization info
  c.filter_sensitive_data("Basic <COMPANIES_HOUSE_API_KEY>") do |interaction|
    interaction.request.headers["Authorization"].first
  end
end
