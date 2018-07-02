Rails.application.routes.draw do
  mount WasteCarriersEngine::Engine => "/"

  root "waste_carriers_engine/registrations#index"
end
