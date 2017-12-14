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

  resources :cbd_type_forms,
            only: [:new, :create],
            path: "cbd-type",
            path_names: { new: "/:reg_identifier" } do
              get "back/:reg_identifier",
              to: "cbd_type_forms#go_back",
              as: "back",
              on: :collection
            end

  resources :renewal_information_forms,
            only: [:new, :create],
            path: "renewal-information",
            path_names: { new: "/:reg_identifier" } do
              get "back/:reg_identifier",
              to: "renewal_information_forms#go_back",
              as: "back",
              on: :collection
            end

  resources :registration_number_forms,
            only: [:new, :create],
            path: "registration-number",
            path_names: { new: "/:reg_identifier" } do
              get "back/:reg_identifier",
              to: "registration_number_forms#go_back",
              as: "back",
              on: :collection
            end

  resources :company_name_forms,
            only: [:new, :create],
            path: "company-name",
            path_names: { new: "/:reg_identifier" } do
              get "back/:reg_identifier",
              to: "company_name_forms#go_back",
              as: "back",
              on: :collection
            end
end
