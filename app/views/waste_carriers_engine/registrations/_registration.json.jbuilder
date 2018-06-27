json.extract! registration, :id, :regIdentifier, :companyName
json.url registration_url(registration, format: :json)
