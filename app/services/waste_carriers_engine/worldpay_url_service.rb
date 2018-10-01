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
      ["&successURL=", build_path(:success)].join
    end

    def pending_url
      ["&pendingURL=", build_path(:pending)].join
    end

    def failure_url
      ["&failureURL=", build_path(:failure)].join
    end

    def cancel_url
      ["&cancelURL=", build_path(:cancel)].join
    end

    def error_url
      ["&errorURL=", build_path(:error)].join
    end

    def build_path(action)
      path = "#{action}_worldpay_forms_path"
      url = [Rails.configuration.host,
             WasteCarriersEngine::Engine.routes.url_helpers.public_send(path, @reg_identifier)]
      CGI.escape(url.join)
    end
  end
end
