class DeclareConvictionsForm < BaseForm
  attr_accessor :declared_convictions

  def initialize(transient_registration)
    super
    self.declared_convictions = @transient_registration.declared_convictions
  end

  def submit(params)
    # Assign the params for validation and pass them to the BaseForm method for updating
    self.declared_convictions = convert_to_boolean(params[:declared_convictions])
    attributes = { declared_convictions: declared_convictions }

    super(attributes, params[:reg_identifier])
  end

  validates :declared_convictions, inclusion: { in: [true, false] }
end
