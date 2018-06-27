class BusinessTypeForm < BaseForm
  include CanNavigateFlexibly

  attr_accessor :business_type

  def initialize(transient_registration)
    super
    self.business_type = @transient_registration.business_type
  end

  def submit(params)
    # Assign the params for validation and pass them to the BaseForm method for updating
    self.business_type = params[:business_type]
    attributes = { business_type: business_type }

    super(attributes, params[:reg_identifier])
  end

  validates :business_type, business_type: true
end
