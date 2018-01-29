class RegistrationNumberForm < BaseForm
  attr_accessor :company_no, :business_type

  def initialize(transient_registration)
    super
    self.company_no = @transient_registration.company_no
    # We only use this for the correct microcopy
    self.business_type = @transient_registration.business_type
  end

  def submit(params)
    # Assign the params for validation and pass them to the BaseForm method for updating
    # If param isn't set, use a blank string instead to avoid errors with the validator
    self.company_no = params[:company_no] || ""
    self.company_no = process_company_no(company_no)
    attributes = { company_no: company_no }

    super(attributes, params[:reg_identifier])
  end

  validates :company_no, presence: true
  validates_with CompanyNoValidator

  private

  def process_company_no(company_no)
    number = company_no.to_s
    # Should be 8 characters, so if it's not, add 0s to the start
    number = "0#{number}" while number.length < 8
    number
  end
end
