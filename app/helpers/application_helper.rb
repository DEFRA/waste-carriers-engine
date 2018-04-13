module ApplicationHelper
  def self.feedback_survey_url(current_title)
    survey_url = "https://www.smartsurvey.co.uk/s/floodexemptions/?"
    survey_params = { referringpage: current_title }
    survey_url + survey_params.to_query
  end

  def title
    title_elements = [title_text, "Register as a waste carrier", "GOV.UK"]
    # Remove empty elements, for example if no specific title is set
    title_elements.delete_if(&:empty?)
    title_elements.join(" - ")
  end

  private

  def title_text
    # Check if the title is set in the view (we do this for High Voltage pages)
    return content_for :title if content_for?(:title)
    # Otherwise, look up translation key based on controller path, action name and .title
    # Solution from https://coderwall.com/p/a1pj7w/rails-page-titles-with-the-right-amount-of-magic
    t("#{controller_path.tr('/', '.')}.#{action_name}.title", default: "")
  end
end
