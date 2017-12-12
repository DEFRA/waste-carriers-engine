class BaseForm
  include ActiveModel::Model

  validates :reg_identifier, presence: true
  validate :transient_registration_valid?

  private

  def transient_registration_valid?
    return if @transient_registration.valid?
    @transient_registration.errors.each do |_attribute, message|
      errors[:base] << message
    end
  end
end
