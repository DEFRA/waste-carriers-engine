# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# Only seed if not running in production or we specifically require it, eg. for Heroku
if !Rails.env.production? || ENV["WCR_ALLOW_SEED"]
  User.find_or_create_by(
    email: "user@waste-exemplar.gov.uk",
    password: ENV["WCR_TEST_USER_PASSWORD"] || "Secret123"
  )

  Registration.find_or_create_by(
    tier: "UPPER",
    registrationType: "carrier_broker_dealer",
    businessType: "limitedCompany",
    otherBusinesses: "yes",
    isMainService: "yes",
    onlyAMF: "no",
    companyName: "Limited Company Seed",
    companyNo: 1_234_567,
    firstName: "Test",
    lastName: "User",
    phoneNumber: "01234 567890",
    contactEmail: "user@waste-exemplar.gov.uk",
    addresses: [
      {
        addressType: "REGISTERED",
        addressMode: "manual-uk",
        houseNumber: "Unit 5",
        addressLine1: "Horizon House",
        addressLine2: "Deanery Road",
        townCity: "Bristol",
        postcode: "BS1 5AH",
        location: {
          lat: 0,
          lon: 0
        }
      },
      {
        addressType: "POSTAL",
        houseNumber: "Richard Fairclough House",
        addressLine1: "Knutsford Road",
        addressLine2: "Latchford",
        addressLine3: "",
        addressLine4: "",
        townCity: "Warrington",
        postcode: "WA4 1HT",
        country: ""
      }
    ],
    keyPeople: [
      {
        firstName: "Test",
        lastName: "Employee",
        dateOfBirth: 40.years.ago,
        position: "Director",
        personType: "KEY",
        convictionSearchResult: {
          matchResult: "NO",
          searchedAt: DateTime.new,
          confirmed: "no"
        }
      }
    ],
    accountEmail: "user@waste-exemplar.gov.uk",
    declaredConvictions: "no",
    declaration: 1,
    regIdentifier: "CBDU1",
    expires_on: 6.months.from_now,
    metaData: {
      dateRegistered: 30.months.ago,
      anotherString: "userDetailAddedAtRegistration",
      lastModified: 29.months.ago,
      dateActivated: 29.months.ago,
      status: "ACTIVE",
      route: "DIGITAL",
      distance: "n/a"
    },
    convictionSearchResult: {
      matchResult: "NO",
      searchedAt: 29.months.ago,
      confirmed: "no"
    }
  )
end
