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
    ["&pendingURL=", failure_path].join
  end

  def failure_url
    ["&failureURL=", failure_path].join
  end

  def cancel_url
    ["&cancelURL=", failure_path].join
  end

  def error_url
    ["&errorURL=", failure_path].join
  end

  def success_path
    url = [Rails.configuration.wcrs_renewals_url,
           Rails.application.routes.url_helpers.success_worldpay_forms_path(@reg_identifier)]
    CGI.escape(url.join)
  end

  def failure_path
    url = [Rails.configuration.wcrs_renewals_url,
           Rails.application.routes.url_helpers.failure_worldpay_forms_path(@reg_identifier)]
    CGI.escape(url.join)
  end
end
