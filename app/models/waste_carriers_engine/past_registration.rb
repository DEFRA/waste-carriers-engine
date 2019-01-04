# frozen_string_literal: true

module WasteCarriersEngine
  # A record of a previous version of the registration. For example, before it was renewed.
  # We store this so we can have a record of each renewal.
  class PastRegistration
    include Mongoid::Document
    include CanHaveRegistrationAttributes

    embedded_in :registration, class_name: "WasteCarriersEngine::Registration"

    def self.build_past_registration(registration)
      past_registration = PastRegistration.new
      return if past_registration.version_already_backed_up?(registration)

      past_registration.registration = registration

      attributes = registration.attributes.except("_id", "past_registrations")
      past_registration.assign_attributes(attributes)

      past_registration.save!
      past_registration
    end

    def version_already_backed_up?(registration)
      # Collect all expires_on dates from past registrations
      matching_expires_on = registration.past_registrations.map(&:expires_on)
      # Check if the current expires_on is included - this indicates that this version of
      # the registration has already been backed up.
      return true if matching_expires_on.include?(registration.expires_on)
    end
  end
end
