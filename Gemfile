source "https://rubygems.org"
ruby "2.4.2"

gem "rails", "4.2.10"
# Use MongoDB as the database - we need to support 2.4
gem "mongo", "2.4.3"
gem "mongoid", "~> 5.2"
# Use SCSS for stylesheets
gem "sass-rails", "~> 5.0"
# Use Uglifier as compressor for JavaScript assets
gem "uglifier", ">= 1.3.0"
# Use CoffeeScript for .coffee assets and views
gem "coffee-rails", "~> 4.1.0"
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem "therubyracer", platforms: :ruby

# Use jquery as the JavaScript library
gem "jquery-rails"
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem "turbolinks"
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem "jbuilder", "~> 2.0"
# bundle exec rake doc:rails generates the API under doc/api.
gem "sdoc", "~> 0.4.0", group: :doc

# Use ActiveModel has_secure_password
# gem "bcrypt", "~> 3.1.7"

# Use Unicorn as the app server
# gem "unicorn"

# Use Capistrano for deployment
# gem "capistrano-rails", group: :development

# Use AASM to manage states and transitions
gem "aasm", "~> 4.12"

# Use Airbrake for error reporting to Errbit
# Version 6 and above cause errors with Errbit, so use 5.8.1 for now
gem "airbrake", "5.8.1"

# Use CanCanCan for user roles and permissions
# Version 2.0 doesn't support Mongoid, so we're locked to an earlier one
gem "cancancan", "~> 1.10"

# Use Devise for user authentication
gem "devise", ">= 4.4.3"

# GOV.UK styling
gem "govuk_elements_rails", "~> 3.1"
gem "govuk_template", "~> 0.23"

# Use High Voltage for static pages
gem "high_voltage", "~> 3.0"

# Use rest-client for external requests, eg. to Companies House
gem "rest-client", "~> 2.0"

gem "secure_headers", "~> 5.0"

# Validations
gem "phonelib", require: false
gem "uk_postcode", require: false
gem "validates_email_format_of", require: false

group :development, :test do
  # Call "byebug" anywhere in the code to stop execution and get a debugger console
  gem "byebug"
  gem "dotenv-rails"
  gem "rspec-rails", "~> 3.6"
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem "web-console", "~> 2.0"

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem "spring"
end

group :production do
  # Used for Heroku logging and asset serving
  gem "rails_12factor"
end

group :test do
  gem "database_cleaner"
  gem "factory_bot_rails"
  gem "simplecov", require: false
  gem "vcr", "~> 4.0"
  gem "webmock", "~> 3.3"
end
gem "loofah", ">= 2.2.1"
gem "rails-html-sanitizer", ">= 1.0.4"
