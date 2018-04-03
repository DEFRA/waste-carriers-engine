class ContactNameForm < BaseForm
  attr_accessor :first_name, :last_name

  def initialize(transient_registration)
    super
    self.first_name = @transient_registration.first_name
    self.last_name = @transient_registration.last_name
  end

  def submit(params)
    # Assign the params for validation and pass them to the BaseForm method for updating
    self.first_name = params[:first_name]
    self.last_name = params[:last_name]
    attributes = {
      first_name: first_name,
      last_name: last_name
    }

    super(attributes, params[:reg_identifier])
  end

  validates :first_name, :last_name, presence: true
  validates :first_name, :last_name, length: { maximum: 70 }
  # Name fields must contain only letters, spaces, commas, full stops, hyphens and apostrophes
  validates_format_of :first_name, :last_name, with: /\A[-a-z\s,.']+\z/i, allow_blank: true
end
