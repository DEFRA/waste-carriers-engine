# frozen_string_literal: true

module WasteCarriersEngine
  module ApplicationHelper
    def self.feedback_survey_url(current_title)
      survey_url = "https://www.smartsurvey.co.uk/s/waste-carriers/?"
      survey_params = { referringpage: current_title }
      survey_url + survey_params.to_query
    end

    def title
      title_elements = [error_title, title_text, "Register as a waste carrier", "GOV.UK"]
      # Remove empty elements, for example if no specific title is set
      title_elements.delete_if(&:blank?)
      title_elements.join(" - ")
    end

    def current_git_commit
      @current_git_commit ||= begin
        sha =
          if Rails.env.development?
            `git rev-parse HEAD`
          else
            heroku_file = Rails.root.join ".source_version"
            capistrano_file = Rails.root.join "REVISION"

            if File.exist? capistrano_file
              File.open(capistrano_file, &:gets)
            elsif File.exist? heroku_file
              File.open(heroku_file, &:gets)
            end
          end

        sha[0...7] if sha.present?
      end
    end

    def display_pence_as_pounds(value_in_pence)
      value_in_pounds = value_in_pence.to_d / 100

      # Check if the value in pounds is a whole number - does dividing it by 1 have a remainder?
      if (value_in_pounds % 1).zero?
        number_with_precision(value_in_pounds, precision: 0).to_s
      else
        number_with_precision(value_in_pounds, precision: 2).to_s
      end
    end

    def displayable_address(address)
      return [] unless address.present?

      # Get all the possible address lines, then remove the blank ones
      [address.house_number,
       address.address_line_1,
       address.address_line_2,
       address.address_line_3,
       address.address_line_4,
       address.town_city,
       address.postcode,
       address.country].reject(&:blank?)
    end

    private

    def title_text
      # Check if the title is set in the view (we do this for High Voltage pages)
      return content_for :title if content_for?(:title)

      # Otherwise, look up translation key based on controller path, action name and .title
      # Solution from https://coderwall.com/p/a1pj7w/rails-page-titles-with-the-right-amount-of-magic
      title = t("#{controller_path.tr('/', '.')}.#{action_name}.title", default: "")
      return title if title.present?

      # Default to title for "new" action if the current action doesn't return anything
      t("#{controller_path.tr('/', '.')}.new.title", default: "")
    end

    def error_title
      content_for :error_title if content_for?(:error_title)
    end
  end
end
