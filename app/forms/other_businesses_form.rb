class OtherBusinessesForm < BaseForm
  attr_accessor :other_businesses

  def initialize(transient_registration)
    super
    self.other_businesses = @transient_registration.other_businesses
  end

  def submit(params)
    # Assign the params for validation and pass them to the BaseForm method for updating
    self.other_businesses = convert_to_boolean(params[:other_businesses])
    attributes = { other_businesses: other_businesses }

    super(attributes, params[:reg_identifier])
  end

  validates :other_businesses, inclusion: { in: [true, false] }
end
