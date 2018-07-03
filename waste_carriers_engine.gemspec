$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "waste_carriers_engine/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "waste_carriers_engine"
  s.version     = WasteCarriersEngine::VERSION
  s.authors     = ["DDTS, DEFRA"]
  s.email       = ["iris.faraway@environment-agency.gov.uk"]
  s.homepage    = "https://github.com/DEFRA"
  s.summary     = "WasteCarriersEngine package containing shared functionality"
  s.description = "WasteCarriersEngine package containing shared functionality"
  s.license     = "The Open Government Licence (OGL) Version 3"

  s.files = Dir["{app,config,db,lib}/**/*", "LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", "4.2.10"
  # Use MongoDB as the database
  s.add_dependency "mongoid", "~> 5.2.0"
  # Use jquery as the JavaScript library
  s.add_dependency "jquery-rails"
  # Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
  s.add_dependency "turbolinks"
  # Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
  s.add_dependency "jbuilder", "~> 2.0"

  # Use AASM to manage states and transitions
  s.add_dependency "aasm", "~> 4.12"

  # Use CanCanCan for user roles and permissions
  # Version 2.0 doesn't support Mongoid, so we're locked to an earlier one
  s.add_dependency "cancancan", "~> 1.10"

  # Use Devise for user authentication
  s.add_dependency "devise", ">= 4.4.3"

  # Use rest-client for external requests, eg. to Companies House
  s.add_dependency "rest-client", "~> 2.0"

  # Use High Voltage for static pages
  s.add_dependency "high_voltage", "~> 3.0"

  # Validations
  s.add_dependency "phonelib"
  s.add_dependency "uk_postcode"
  s.add_dependency "validates_email_format_of"

  # Used to build and parse XML requests
  s.add_dependency "nokogiri"

  # Used to get a 2-character country code for Worldpay
  s.add_dependency "countries"
end
