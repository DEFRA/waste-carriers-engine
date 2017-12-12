# Waste Carriers renewals

[![Build Status](https://travis-ci.org/DEFRA/waste-carriers-renewals.svg?branch=master)](https://travis-ci.org/DEFRA/waste-carriers-renewals) [![Maintainability](https://api.codeclimate.com/v1/badges/414c0f88f3f030452da8/maintainability)](https://codeclimate.com/github/DEFRA/waste-carriers-renewals/maintainability) [![Test Coverage](https://api.codeclimate.com/v1/badges/414c0f88f3f030452da8/test_coverage)](https://codeclimate.com/github/DEFRA/waste-carriers-renewals/test_coverage) [![security](https://hakiri.io/github/DEFRA/waste-carriers-renewals/master.svg)](https://hakiri.io/github/DEFRA/waste-carriers-renewals/master) [![Dependency Status](https://dependencyci.com/github/DEFRA/waste-carriers-renewals/badge)](https://dependencyci.com/github/DEFRA/waste-carriers-renewals)

The Waste Carrier Registrations Service allows businesses, who deal with waste and thus have to register according to the regulations, to register online. Once registered, businesses can sign in again to edit their registrations if needed.

The service also allows authorised agency users and NCCC contact centre staff to create and manage registrations on other users behalf, e.g. to support 'Assisted Digital' registrations. The service provides an internal user account management facility which allows authorised administrators to create and manage other agency user accounts.

The renewals application allows users who registered using the Waste Carrier Registrations Service to renew their registrations.

## Prerequisites

Make sure you already have:

- Git
- Ruby 2.4.2
- Rails 4.2.10
- [Bundler](http://bundler.io/) – for installing Ruby gems
- MongoDb

## Installation

A Vagrantfile has been created allowing easy setup of the waste carriers applications, databases and dependencies. This is located within Gitlab.

Download the Vagrantfile and run the VM using `vagrant up`. Once the VM is set up and has installed all the other elements of the Waste Carriers service, you can install the renewals application.

You can do this on your local machine, but make sure the VM is also up and running.

Clone the repo:

`git clone git@gitlab-dev.aws-int.defra.cloud:waste-carriers/waste-carriers-renewals.git`

Change to the directory:

`cd waste-carriers-renewals`

And install the dependencies:

`bundle install`

### Databases

Registration data and user data for the Waste Carriers service are held in 2 MongoDb databases. Multiple applications for the service use these databases, including this one.

If you are using the Vagrant image, running `vagrant up` should set up the development databases for registrations and users.

The renewals application also has 2 separate test databases. Currently you will need to create these yourself. Create these on the VM.

`mongo waste-carriers-test --eval 'db.addUser({user: "mongoUser", pwd: "password1234", roles:["readWrite", "dbAdmin", "userAdmin"]})'`

`mongo waste-carriers-users-test --eval 'db.addUser({user: "mongoUser", pwd: "password1234", roles:["readWrite", "dbAdmin", "userAdmin"]})'`

If you get a permissions error when trying to create the databases, you may need to remove the auth requirements in `/etc/mongodb.conf`. Restart Mongo after doing this for changes to take effect.

### Seed data

The renewals application relies on users being created as part of waste-carriers-frontend. You should not be able to create a new user as part of a renewal.

However, you can seed the database with a test user so you can log in and access the features. (This won't work in production.)

Seed the databases with:

`bundle exec rake db:seed`

## Running the application

Make sure the Vagrant image with the databases is up and running.

Start the application with:

`bundle exec rails s -p 3001`

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
