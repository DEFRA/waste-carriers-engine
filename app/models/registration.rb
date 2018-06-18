class Registration
  include Mongoid::Document
  include CanHaveRegistrationAttributes
  include CanGenerateRegIdentifier

  embeds_many :past_registrations
  accepts_nested_attributes_for :past_registrations

  before_validation :generate_reg_identifier, on: :create

  validates :reg_identifier,
            :addresses,
            :metaData,
            presence: true

  validates :reg_identifier,
            uniqueness: true

  validates :tier,
            inclusion: { in: %w[UPPER LOWER] }
end
