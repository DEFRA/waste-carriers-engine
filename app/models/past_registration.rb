# A record of a previous version of the registration. For example, before it was renewed.
# We store this so we can have a record of each renewal.
class PastRegistration
  include Mongoid::Document
  include CanHaveRegistrationAttributes

  embedded_in :registration

  def self.build_past_registration(registration)
    past_registration = PastRegistration.new
    past_registration.registration = registration

    attributes = registration.attributes.except(:_id, :past_registrations)
    past_registration.assign_attributes(attributes)

    past_registration
  end
end
