module BaseFormsHelper
  # The standard behaviour for loading a form is to check whether the requested form matches the workflow_state for
  # the transient registration, and redirect to the saved workflow_state if it doesn't.
  # But if the workflow state is 'flexible' (listed below), then we skip this check and load the requested form.
  # This means users can still navigate by using the browser back button and reload forms which don't match the
  # saved workflow_state. We then update the workflow_state to match their request, rather than the other way around.
  # These are generally forms after 'renewal_start_form' but before 'declaration_form'.
  def flexible_states
    %i[location_form
       register_in_northern_ireland_form
       register_in_scotland_form
       register_in_wales_form
       business_type_form
       cannot_renew_lower_tier_form
       cannot_renew_type_change_form
       cannot_renew_company_no_change_form
       tier_check_form
       other_businesses_form
       service_provided_form
       construction_demolition_form
       waste_types_form
       cbd_type_form
       renewal_information_form
       registration_number_form
       company_name_form
       company_postcode_form
       company_address_form
       company_address_manual_form
       main_people_form
       declare_convictions_form
       conviction_details_form
       contact_name_form
       contact_phone_form
       contact_email_form
       contact_postcode_form
       contact_address_form
       contact_address_manual_form
       check_your_answers_form]
  end
end
