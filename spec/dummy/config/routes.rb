Rails.application.routes.draw do
  mount WasteCarriersEngine::Engine => "/"

  devise_for :users
  devise_scope :user do
    get "/users/sign_out" => "devise/sessions#destroy"
  end

  root "waste_carriers_engine/registrations#index"
end
