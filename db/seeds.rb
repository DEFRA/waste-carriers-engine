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

  Dir.glob("#{Rails.root}/db/seeds/*.json").each do |file|
    Registration.find_or_create_by(JSON.parse(File.read(file)))
  end
end
