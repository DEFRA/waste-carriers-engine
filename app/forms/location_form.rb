class LocationForm < BaseForm
  attr_accessor :location

  def initialize(transient_registration)
    super
    self.location = @transient_registration.location
  end

  def submit(params)
    # Assign the params for validation and pass them to the BaseForm method for updating
    self.location = params[:location]
    attributes = { location: location }

    # Set the business type to overseas when required as we use this for microcopy
    attributes[:business_type] = "overseas" if location == "overseas"

    super(attributes, params[:reg_identifier])
  end

  validates :location, inclusion: { in: %w[england
                                           northern_ireland
                                           scotland
                                           wales
                                           overseas] }
end
