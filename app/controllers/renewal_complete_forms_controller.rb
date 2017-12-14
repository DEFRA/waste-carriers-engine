class RenewalCompleteFormsController < FormsController
  def new
    super(RenewalCompleteForm, "renewal_complete_form")
  end

  # Overwrite create and go_back as you shouldn't be able to submit or go back
  def create; end

  def go_back; end
end
