# frozen_string_literal: true

source "https://rubygems.org"

ruby "3.2.2"

# Temporary workaround until we implement webpack assets
# See: https://github.com/sass/sassc-rails/issues/114
gem "sassc-rails"

# Declare your gem's dependencies in waste_carriers_engine.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

# GOV.UK styling
gem "defra_ruby_template", "~> 3.13.0"

gem "mongo_session_store"

# Use CanCanCan for user roles and permissions
gem "cancancan", "~> 3.5.0"

# Use Devise for user authentication
gem "devise", "~> 4.9.2"

gem "matrix", "~> 0.4.2"

gem "secure_headers", "~> 6.5.0"

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem "turbolinks", "~> 5.2.1"

group :development, :test do
  # Call "binding.pry" anywhere in the code to stop execution and get a debugger console
  gem "pry-byebug", "~> 3.10.1"

  # Apply our style guide to ensure consistency in how the code is written
  gem "defra_ruby_style", "~> 0.3.0"

  gem "dotenv-rails", "~> 2.8.1"

  gem "rspec-rails", "~> 6.0.3"

  gem "rubocop-rspec", "~> 2.22.0", require: false

end

# Remainder of Gemfile.lock omitted for brevity

group :development do
  # Allows us to automatically generate the change log from the tags, issues,
  # labels and pull requests on GitHub. Added as a dependency so all dev's have
  # access to it to generate a log, and so they are using the same version.
  # New dev's should first create GitHub personal app token and add it to their
  # ~/.bash_profile (or equivalent)
  # https://github.com/skywinder/github-changelog-generator#github-token
  gem "github_changelog_generator", "~> 1.16.4"

  # Access an IRB console on exception pages or by using <%= console %> in views
  gem "web-console", "~> 4.2.0"

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem "spring", "~> 4.1.1"

  gem "spring-commands-rspec", "~> 1.0.4"

  gem "stateoscope", "~> 0.1.3", group: :development

end

group :test do

  gem "database_cleaner-mongoid", "~> 2.0.1"

  gem "factory_bot_rails", "~> 6.2.0", require: false

  gem "faker", "~> 3.2.0"

  gem "govuk_design_system_formbuilder", "~> 4.1.1"

  gem "rails-controller-testing", "~> 1.0.5"

  gem "rspec-html-matchers", "~> 0.10.0"

  gem "simplecov", "~> 0.22.0", require: false

  gem "timecop", "~> 0.9.6"

  gem "vcr", "~> 6.2.0"

  gem "webmock", "~> 3.18.1"

end
