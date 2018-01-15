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

  seeds = []
  Dir.glob("#{Rails.root}/db/seeds/*.json").each do |file|
    seeds << JSON.parse(File.read(file))
  end

  # Sort seeds to list ones with regIdentifiers first
  sorted_seeds = seeds.select { |s| s.key?("regIdentifier") } + seeds.reject { |s| s.key?("regIdentifier") }

  sorted_seeds.each do |seed|
    Registration.find_or_create_by(seed.except("_id"))
  end
end
