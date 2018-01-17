class ServiceProvidedForm < BaseForm
  attr_accessor :is_main_service

  def initialize(transient_registration)
    super
    self.is_main_service = @transient_registration.is_main_service
  end

  def submit(params)
    # Assign the params for validation and pass them to the BaseForm method for updating
    self.is_main_service = convert_to_boolean(params[:is_main_service])
    attributes = { is_main_service: is_main_service }

    super(attributes, params[:reg_identifier])
  end

  validates :is_main_service, inclusion: { in: [true, false] }
end
