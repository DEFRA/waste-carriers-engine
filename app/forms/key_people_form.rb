class KeyPeopleForm < BaseForm
  attr_accessor :business_type
  attr_accessor :first_name, :last_name, :dob_day, :dob_month, :dob_year

  def initialize(transient_registration)
    super
    # We only use this for the correct microcopy
    self.business_type = @transient_registration.business_type
  end

  def submit(params)
    # Assign the params for validation and pass them to the BaseForm method for updating
    self.first_name = params[:first_name]
    self.last_name = params[:last_name]
    self.dob_day = params[:dob_day].to_i
    self.dob_month = params[:dob_month].to_i
    self.dob_year = params[:dob_year].to_i

    attributes = { keyPeople: add_key_person }

    super(attributes, params[:reg_identifier])
  end

  validates :first_name, presence: true, length: { maximum: 35 }
  validates :last_name, presence: true, length: { maximum: 35 }
  validates_with DobValidator

  private

  def add_key_person
    [KeyPerson.new(first_name: first_name,
                   last_name: last_name,
                   dob_day: dob_day,
                   dob_month: dob_month,
                   dob_year: dob_year,
                   person_type: "key")]
  end
end
