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

    super(attributes, params[:reg_identifier])
  end
end
