class Registration
  include Mongoid::Document
  include CanHaveRegistrationAttributes

  validates :reg_identifier,
            :addresses,
            :metaData,
            presence: true

  validates :reg_identifier,
            uniqueness: true
end
