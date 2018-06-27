source "https://rubygems.org"
ruby "2.4.2"

# Declare your gem's dependencies in flood_risk_engine.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

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
  gem "timecop"
  gem "vcr", "~> 4.0"
  gem "webmock", "~> 3.4"
end
gem "loofah", ">= 2.2.1"
gem "rails-html-sanitizer", ">= 1.0.4"
