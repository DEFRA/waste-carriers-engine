Rails.application.routes.draw do
  mount WasteCarriersEngine::Engine => "/engine"

  root "waste_carriers_engine/registrations#index"
end
