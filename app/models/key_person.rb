class KeyPerson
  include Mongoid::Document

  embedded_in :registration
  embeds_one :convictionSearchResult

  accepts_nested_attributes_for :convictionSearchResult

  after_initialize :set_date_of_birth

  field :firstName, as: :first_name,       type: String
  field :lastName, as: :last_name,         type: String
  field :position,                         type: String
  field :dob_day,                          type: Integer
  field :dob_month,                        type: Integer
  field :dob_year,                         type: Integer
  field :dateOfBirth, as: :date_of_birth,  type: DateTime
  field :personType, as: :person_type,     type: String

  private

  def set_date_of_birth
    return unless dob_year.present? && dob_year.positive?
    return unless dob_month.present? && dob_month.positive?
    return unless dob_day.present? && dob_day.positive?
    self.date_of_birth = Date.new(dob_year, dob_month, dob_day)
  end
end
