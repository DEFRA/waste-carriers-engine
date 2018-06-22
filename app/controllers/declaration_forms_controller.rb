class DeclarationFormsController < FormsController
  def new
    super(DeclarationForm, "declaration_form")
  end

  def create
    return unless super(DeclarationForm, "declaration_form")

    entity_matching_service = EntityMatchingService.new(@transient_registration)
    entity_matching_service.check_business_for_matches
    entity_matching_service.check_people_for_matches
  end
end
