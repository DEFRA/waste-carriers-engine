VCR.configure do |c|
  c.cassette_library_dir = "spec/cassettes"
  c.hook_into :webmock

  c.ignore_hosts "127.0.0.1", "codeclimate.com"
  c.filter_sensitive_data("key_goes_here") { Rails.configuration.companies_house_api_key }
end
