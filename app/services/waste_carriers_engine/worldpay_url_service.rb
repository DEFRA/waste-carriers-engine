# frozen_string_literal: true

module WasteCarriersEngine
  # Builds the URL we use to redirect users to Worldpay.
  # This should include URLs for our own service, which Worldpay will redirect users to after payment.
  class WorldpayUrlService
    def initialize(reg_identifier, base_url)
      @reg_identifier = reg_identifier
      @base_url = base_url
    end

    def format_link
      [@base_url,
       redirect_url_for(:success),
       redirect_url_for(:pending),
       redirect_url_for(:failure),
       redirect_url_for(:cancel),
       redirect_url_for(:error)].join
    end

    private

    def redirect_url_for(action)
      param_name = "&#{action}URL="
      param_value = build_path_for(action)
      [param_name, param_value].join
    end

    def build_path_for(action)
      path = "#{action}_worldpay_forms_path"
      url = [Rails.configuration.host,
             WasteCarriersEngine::Engine.routes.url_helpers.public_send(path, @reg_identifier)]
      CGI.escape(url.join)
    end
  end
end
