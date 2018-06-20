class RenewalCompletionService
  def initialize(transient_registration)
    @transient_registration = transient_registration
    @registration = find_original_registration
  end

  def complete_renewal
    return :error unless valid_renewal?
    create_past_registration
    update_registration
    delete_transient_registration
  end

  private

  def find_original_registration
    Registration.where(reg_identifier: @transient_registration.reg_identifier).first
  end

  def valid_renewal?
    @registration.metaData.may_renew?
  end

  def create_past_registration
    PastRegistration.build_past_registration(@registration)
  end

  def update_registration
    copy_data_from_transient_registration
    @registration.metaData.renew
    @registration.save!
  end

  def delete_transient_registration
    @transient_registration.delete
  end

  def copy_data_from_transient_registration
    attributes = @transient_registration.attributes.except("_id",
                                                           "workflow_state",
                                                           "temp_cards",
                                                           "temp_company_postcode",
                                                           "temp_contact_postcode",
                                                           "temp_os_places_error",
                                                           "temp_payment_method",
                                                           "temp_tier_check")
    @registration.write_attributes(attributes)

    # If attributes aren't included in the transient_registration, for example if the user skipped the tier check,
    # update those attributes to be nil for the registration
    registration_attributes = @registration.attributes.except("_id", "past_registrations").keys
    registration_attributes.each do |attribute|
      next if attributes.keys.include?(attribute)
      @registration[attribute] = nil
    end
  end
end
