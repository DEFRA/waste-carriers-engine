unless Rails.application.config.consider_all_requests_local
  Rails.application.config.exceptions_app = WasteCarriersEngine::Engine.routes
end
