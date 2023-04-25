# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

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
  s.metadata["rubygems_mfa_required"] = "true"
  s.required_ruby_version = ">= 3.1.2"

  s.files = Dir["{app,config,db,lib}/**/*", "LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "rails", ">= 6.1.4"
  # Use MongoDB as the database
  s.add_dependency "mongoid"
  # Implement document-level locking
  # Note v2.0.1 interferes with the delegate method
  s.add_dependency "mongoid-locker", "2.0.0"

  # Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
  s.add_dependency "turbolinks"
  # Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
  s.add_dependency "jbuilder", "~> 2.11"

  # Use AASM to manage states and transitions
  s.add_dependency "aasm", "~> 5.3"

  # Use rest-client for external requests, eg. to Companies House
  s.add_dependency "rest-client", "~> 2.1"

  # Use High Voltage for static pages
  s.add_dependency "high_voltage", "~> 3.1"

  # Validations
  s.add_dependency "defra_ruby_validators", ">= 2.5.0"
  s.add_dependency "uk_postcode"

  # defra_ruby_alert is a gem we created to manage airbrake across projects
  s.add_dependency "defra_ruby_alert", "~> 2.1"

  # Used to handle requests to the address lookup web service used (currently
  # EA Address Facade v1)
  s.add_dependency "defra_ruby_address"

  # Used as part of testing. When enabled adds a /last-email route from which
  # details of the last email sent by the app can be accessed
  s.add_dependency "defra_ruby_email"

  # Use Notify to send emails and letters
  s.add_dependency "notifications-ruby-client"

  # Used to build and parse XML requests
  s.add_dependency "nokogiri"

  # Used to get a 2-character country code for Worldpay
  s.add_dependency "countries"

  # Used to generate a PDF from HTML, in our case, the users certificate
  s.add_dependency "wicked_pdf"

  s.add_dependency "defra_ruby_area", "~> 2.0"
end
