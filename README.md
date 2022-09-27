# Waste Carriers engine

![Build Status](https://github.com/DEFRA/waste-carriers-engine/workflows/CI/badge.svg?branch=main)
[![Maintainability Rating](https://sonarcloud.io/api/project_badges/measure?project=DEFRA_waste-carriers-engine&metric=sqale_rating)](https://sonarcloud.io/dashboard?id=DEFRA_waste-carriers-engine)
[![Coverage](https://sonarcloud.io/api/project_badges/measure?project=DEFRA_waste-carriers-engine&metric=coverage)](https://sonarcloud.io/dashboard?id=DEFRA_waste-carriers-engine)
[![Licence](https://img.shields.io/badge/Licence-OGLv3-blue.svg)](http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3)

The 'Register as a waste carrier' service allows businesses, who deal with waste and have to register according to the regulations, to register online. Once registered, businesses can sign in again to edit their registrations if needed.

The service also allows authorised agency users and NCCC staff to create and manage registrations on other users' behalf, e.g. to support 'Assisted Digital' registrations. The service provides an internal user account management facility which allows authorised administrators to create and manage other agency user accounts.

The waste-carriers-engine allows users who registered using the 'Register as a waste carrier' service to renew their registrations.

The engine is mounted in [waste-carriers-front-office](https://github.com/DEFRA/waste-carriers-front-office) and [waste-carriers-back-office](https://github.com/DEFRA/waste-carriers-back-office).

## Prerequisites

Make sure you already have:

- Git
- Ruby 3.1.2
- [Bundler](http://bundler.io/) – for installing Ruby gems
- MongoDb 3.6

The engine also expects these gems to be installed in the application in which it is mounted:

- [Devise](https://github.com/plataformatec/devise/) >= 4.4.3
- [CanCanCan](https://github.com/CanCanCommunity/cancancan) ~> 1.10

And for a User model to be in place. See the [dummy testing app](https://github.com/DEFRA/waste-carriers-engine/tree/master/spec/dummy) for an example of how this might be implemented.

## Mounting the engine

Add the engine to your Gemfile:

```
gem "waste_carriers_engine",
    git: "https://github.com/DEFRA/waste-carriers-engine"
```

Install it with `bundle install`.

Set up all the required environment variables and load them into the application. See .env.example and config/application.rb for an indication of what values you need.

Create a new file at config/initializers/waste_carriers_engine.rb and add:

```
WasteCarriersEngine::VERSION = Gem.loaded_specs["waste_carriers_engine"].version
```

Then mount the engine in your routes.rb file:

```
Rails.application.routes.draw do
  mount WasteCarriersEngine::Engine => "/"
end
```

The engine should now be mounted at the root of your project. You can change `"/"` to a different route if you'd prefer it to be in a subdirectory.

For more info, see [how the engine was mounted in waste-carriers-front-office](https://github.com/DEFRA/waste-carriers-front-office/pull/2).

## Installation

You don't need to do this if you're just mounting the engine without making any changes.

However, if you want to edit the engine, you'll have to install it locally.

Clone the repo and drop into the project:

```bash
git clone https://github.com/DEFRA/waste-carriers-engine.git && cd waste-carriers-engine`
```

Then install the dependencies with `bundle install`.

## Testing the engine

The engine is mounted in a dummy Rails 4 app (in /spec/dummy) so we can properly test its behaviour.

The test suite is written in RSpec.

To run all the tests, use:

`bundle exec rspec`

### .env

While many of the tests stub environment variables, you may still need to set them for accurate testing.

The dummy project uses the [Dotenv gem](https://github.com/bkeepers/dotenv) to load environment variables when the app starts. Dotenv expects to find a .env file in the project root. For the dummy, the root is /spec/dummy/

Duplicate .env.example and rename the copy as .env

Open it and update the settings as required.

## Contributing to this project

If you have an idea you'd like to contribute please log an issue.

All contributions should be submitted via a pull request.

## License

THIS INFORMATION IS LICENSED UNDER THE CONDITIONS OF THE OPEN GOVERNMENT LICENCE found at:

http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3

The following attribution statement MUST be cited in your products and applications when using this information.

> Contains public sector information licensed under the Open Government license v3

### About the license

The Open Government Licence (OGL) was developed by the Controller of Her Majesty's Stationery Office (HMSO) to enable information providers in the public sector to license the use and re-use of their information under a common open licence.

It is designed to encourage use and re-use of information freely and flexibly, with only a few conditions.
