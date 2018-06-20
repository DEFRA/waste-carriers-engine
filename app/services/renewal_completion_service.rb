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
    # TODO: Copy data from transient_registration
    @registration.metaData.renew
    @registration.save!
  end

  def delete_transient_registration
    @transient_registration.delete
  end
end
