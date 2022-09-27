# frozen_string_literal: true

source "https://rubygems.org"
ruby "3.1.2"

# Temporary workaround until we implement webpack assets
# See: https://github.com/sass/sassc-rails/issues/114
gem "sassc-rails"

# Declare your gem's dependencies in waste_carriers_engine.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

# GOV.UK styling
gem "defra_ruby_template"

# Use MongoDB as the database
gem "mongoid", "~> 7.5"
# Implement document-level locking
gem "mongoid-locker", "~> 2.0.0"

# Use CanCanCan for user roles and permissions
gem "cancancan", "~> 3.3"

# Use Devise for user authentication
gem "devise", ">= 4.8"

gem "matrix"

gem "net-smtp"

gem "secure_headers", "~> 6.3"

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem "turbolinks"

group :development, :test do
  # Call "binding.pry" anywhere in the code to stop execution and get a debugger console
  gem "pry-byebug"
  # Apply our style guide to ensure consistency in how the code is written
  gem "defra_ruby_style"
  gem "dotenv-rails"
  gem "rspec-rails"
  gem "rubocop-rspec", require: false
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem "web-console"

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem "spring"
  gem "spring-commands-rspec"

  gem "stateoscope", "~> 0.1.3", group: :development
end

group :test do
  gem "database_cleaner-mongoid"
  gem "factory_bot_rails", require: false
  gem "faker"
  gem "govuk_design_system_formbuilder"
  gem "rails-controller-testing"
  gem "rspec-html-matchers"
  gem "simplecov", "~> 0.17.1", require: false
  gem "timecop"
  gem "vcr"
  gem "webmock", "~> 3.4"
end
