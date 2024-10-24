Rails.application.routes.draw do
  mount WasteCarriersEngine::Engine => "/"

  root "waste_carriers_engine/registrations#index"

  resources :registrations,
            only: :show,
            param: :reg_identifier,
            path: "/bo/registrations"
end
