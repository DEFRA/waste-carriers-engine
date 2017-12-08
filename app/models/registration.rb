class Registration
  include Mongoid::Document
  include CanHaveRegistrationAttributes

  validates :regIdentifier,
            :addresses,
            :metaData,
            presence: true
end
