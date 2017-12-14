Rails.application.routes.draw do
  devise_for :users
  devise_scope :user do
    get "/users/sign_out" => "devise/sessions#destroy"
  end

  root "registrations#index"

  resources :registrations

  resources :renewal_start_forms,
            only: [:new, :create],
            path: "renew",
            path_names: { new: "/:reg_identifier" }

  resources :business_type_forms,
            only: [:new, :create],
            path: "business-type",
            path_names: { new: "/:reg_identifier" } do
              get "back/:reg_identifier",
              to: "business_type_forms#go_back",
              as: "back",
              on: :collection
            end

  resources :smart_answers_forms,
            only: [:new, :create],
            path: "smart-answers",
            path_names: { new: "/:reg_identifier" } do
              get "back/:reg_identifier",
              to: "smart_answers_forms#go_back",
              as: "back",
              on: :collection
            end
end
