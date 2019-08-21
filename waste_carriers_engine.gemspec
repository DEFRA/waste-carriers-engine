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

  s.files = Dir["{app,config,db,lib}/**/*", "LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", "~> 4.2.11"
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

  # Use rest-client for external requests, eg. to Companies House
  s.add_dependency "rest-client", "~> 2.0"

  # Use High Voltage for static pages
  s.add_dependency "high_voltage", "~> 3.0"

  # Validations
  s.add_dependency "defra_ruby_validators"
  s.add_dependency "uk_postcode"

  # Used to build and parse XML requests
  s.add_dependency "nokogiri"

  # Used to get a 2-character country code for Worldpay
  s.add_dependency "countries"

  # Allows us to automatically generate the change log from the tags, issues,
  # labels and pull requests on GitHub. Added as a dependency so all dev's have
  # access to it to generate a log, and so they are using the same version.
  # New dev's should first create GitHub personal app token and add it to their
  # ~/.bash_profile (or equivalent)
  # https://github.com/skywinder/github-changelog-generator#github-token
  s.add_development_dependency "github_changelog_generator"

  # Used to generate a PDF from HTML, in our case, the users certificate
  s.add_dependency "wicked_pdf"
end
