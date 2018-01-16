class ServiceProvidedFormsController < FormsController
  def new
    super(ServiceProvidedForm, "service_provided_form")
  end

  def create
    super(ServiceProvidedForm, "service_provided_form")
  end
end
