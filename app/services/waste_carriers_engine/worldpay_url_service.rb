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
       success_url,
       pending_url,
       failure_url,
       cancel_url,
       error_url].join
    end

    private

    def success_url
      ["&successURL=", success_path].join
    end

    def pending_url
      ["&pendingURL=", pending_path].join
    end

    def failure_url
      ["&failureURL=", failure_path].join
    end

    def cancel_url
      ["&cancelURL=", cancel_path].join
    end

    def error_url
      ["&errorURL=", error_path].join
    end

    def success_path
      url = [Rails.configuration.host,
             WasteCarriersEngine::Engine.routes.url_helpers.success_worldpay_forms_path(@reg_identifier)]
      CGI.escape(url.join)
    end

    def pending_path
      url = [Rails.configuration.host,
             WasteCarriersEngine::Engine.routes.url_helpers.pending_worldpay_forms_path(@reg_identifier)]
      CGI.escape(url.join)
    end

    def failure_path
      url = [Rails.configuration.host,
             WasteCarriersEngine::Engine.routes.url_helpers.failure_worldpay_forms_path(@reg_identifier)]
      CGI.escape(url.join)
    end

    def cancel_path
      url = [Rails.configuration.host,
             WasteCarriersEngine::Engine.routes.url_helpers.cancel_worldpay_forms_path(@reg_identifier)]
      CGI.escape(url.join)
    end

    def error_path
      url = [Rails.configuration.host,
             WasteCarriersEngine::Engine.routes.url_helpers.error_worldpay_forms_path(@reg_identifier)]
      CGI.escape(url.join)
    end
  end
end
