class KeyPerson
  include Mongoid::Document

  embedded_in :registration
  embeds_one :convictionSearchResult

  accepts_nested_attributes_for :convictionSearchResult

  # TODO: Confirm types
  field :firstName,    type: String
  field :lastName,     type: String
  field :position,     type: String
  # Do we need all these date fields? TODO: Compare against existing DB
  field :dob_day,      type: Integer
  field :dob_month,    type: Integer
  field :dob_year,     type: Integer
  field :dateOfBirth,  type: DateTime
  field :personType,   type: String # "Key" by default, but why would you add an irrelevant person?

  validates :firstName, :lastName, :position, :dateOfBirth, :personType,
            presence: true
end
