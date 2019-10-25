# frozen_string_literal: true

module FormRequestHelpers
  def post_form_with_params(form, params)
    post create_path_for(form), params_for_form(form, params)
  end

  # Should call a method like location_forms_path
  def create_path_for(form)
    send("#{form}s_path")
  end

  # Should output a hash like { location_forms: params }
  def params_for_form(form, params)
    hash = {}
    hash[form.to_sym] = params
    hash
  end
end

RSpec.configure do |config|
  config.include FormRequestHelpers
end
