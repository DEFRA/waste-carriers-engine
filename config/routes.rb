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

  resources :company_postcode_forms,
            only: [:new, :create],
            path: "company-postcode",
            path_names: { new: "/:reg_identifier" } do
              get "back/:reg_identifier",
              to: "company_postcode_forms#go_back",
              as: "back",
              on: :collection
            end

  resources :company_address_forms,
            only: [:new, :create],
            path: "company-address",
            path_names: { new: "/:reg_identifier" } do
              get "back/:reg_identifier",
              to: "company_address_forms#go_back",
              as: "back",
              on: :collection
            end

  resources :key_people_director_forms,
            only: [:new, :create],
            path: "key-people-director",
            path_names: { new: "/:reg_identifier" } do
              get "back/:reg_identifier",
              to: "key_people_director_forms#go_back",
              as: "back",
              on: :collection
            end

  resources :declare_convictions_forms,
            only: [:new, :create],
            path: "declare-convictions",
            path_names: { new: "/:reg_identifier" } do
              get "back/:reg_identifier",
              to: "declare_convictions_forms#go_back",
              as: "back",
              on: :collection
            end

  resources :conviction_details_forms,
            only: [:new, :create],
            path: "conviction-details",
            path_names: { new: "/:reg_identifier" } do
              get "back/:reg_identifier",
              to: "conviction_details_forms#go_back",
              as: "back",
              on: :collection
            end

  resources :contact_name_forms,
            only: [:new, :create],
            path: "contact-name",
            path_names: { new: "/:reg_identifier" } do
              get "back/:reg_identifier",
              to: "contact_name_forms#go_back",
              as: "back",
              on: :collection
            end

  resources :contact_phone_forms,
            only: [:new, :create],
            path: "contact-phone",
            path_names: { new: "/:reg_identifier" } do
              get "back/:reg_identifier",
              to: "contact_phone_forms#go_back",
              as: "back",
              on: :collection
            end

  resources :contact_email_forms,
            only: [:new, :create],
            path: "contact-email",
            path_names: { new: "/:reg_identifier" } do
              get "back/:reg_identifier",
              to: "contact_email_forms#go_back",
              as: "back",
              on: :collection
            end
end
