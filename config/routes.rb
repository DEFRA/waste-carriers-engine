Rails.application.routes.draw do
  devise_for :users
  devise_scope :user do
    get "/users/sign_out" => "devise/sessions#destroy"
  end

  resources :registrations
  resources :contact_details_forms, only: [:new, :create], path_names: { new: "/:id", create: "/update/:id" }

  root "registrations#index"
end
