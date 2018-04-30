# Waste Carriers renewals

[![Build Status](https://travis-ci.org/DEFRA/waste-carriers-renewals.svg?branch=master)](https://travis-ci.org/DEFRA/waste-carriers-renewals)
[![Maintainability](https://api.codeclimate.com/v1/badges/414c0f88f3f030452da8/maintainability)](https://codeclimate.com/github/DEFRA/waste-carriers-renewals/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/414c0f88f3f030452da8/test_coverage)](https://codeclimate.com/github/DEFRA/waste-carriers-renewals/test_coverage)
[![security](https://hakiri.io/github/DEFRA/waste-carriers-renewals/master.svg)](https://hakiri.io/github/DEFRA/waste-carriers-renewals/master)

The 'Register as a waste carrier' service allows businesses, who deal with waste and have to register according to the regulations, to register online. Once registered, businesses can sign in again to edit their registrations if needed.

The service also allows authorised agency users and NCCC staff to create and manage registrations on other users' behalf, e.g. to support 'Assisted Digital' registrations. The service provides an internal user account management facility which allows authorised administrators to create and manage other agency user accounts.

The waste-carriers-renewals application allows users who registered using the 'Register as a waste carrier' service to renew their registrations.

## Prerequisites

Make sure you already have:

- Git
- Ruby 2.4.2
- [Bundler](http://bundler.io/) – for installing Ruby gems
- MongoDb 3.6

## Installation

Clone the repo and drop into the project:

```bash
git clone https://github.com/DEFRA/waste-carriers-renewals.git && cd waste-carriers-renewals`
```

Then install the dependencies with `bundle install`.

## Running locally

A [Vagrant](https://www.vagrantup.com/) instance has been created allowing easy setup of the waste carriers service. It includes installing all applications, databases and dependencies. This is located within GitLab (speak to the Ruby team).

Download the Vagrant project and create the VM using the instructions in its README. It includes installing and running a version of the renewals app.

However, if you intend to work with the renewals app locally (as opposed to on the Vagrant instance) and just use the box for dependencies, you'll need to:

- Log in into the Vagrant instance
- Using `ps ax`, identify the pid of the running renewals app
- Kill it using `kill [pid id]`
- Exit the vagrant instance

Once you've created a `.env` file (see below) you should be ready to work with and run the project locally.

## .env

The project uses the [Dotenv gem](https://github.com/bkeepers/dotenv) to load environment variables when the app starts. Dotenv expects to find a .env file in the project root.

Duplicate .env.example and rename the copy as .env

Open it and update the settings as required.

## Databases

If you are running the waste carriers Vagrant VM, you have nothing to do! All databases are already created and the appropriate ports opened for access from the host to the VM.

If you intend to run it standalone, you'll need to create databases for the develop and test environments. There are 2 separate MongoDb databases for registration data and user data, so you'll need to create 4 databases in total. Multiple applications for the service use these databases, including this one.

### Seed data

The renewals application relies on users being created as part of waste-carriers-frontend. You should not be able to create a new user as part of a renewal.

However, you can seed the database with a test user so you can log in and access the features (this won't work in production).

Seed the databases with:

`bundle exec rake db:seed`

## Running the application

Make sure the Vagrant image with the databases is up and running.

Start the application with:

`bundle exec rails s -p 3002`

The port change is to avoid a clash with waste-carriers-frontend.

## Testing the app

The test suite is written in RSpec.

To run all the tests, use:

`bundle exec rspec`

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
