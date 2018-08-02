WasteCarriersEngine::Engine.routes.draw do
  resources :registrations, only: [:index]

  resources :renewal_start_forms,
            only: [:new, :create],
            path: "renew",
            path_names: { new: "/:reg_identifier" }

  resources :location_forms,
            only: [:new, :create],
            path: "location",
            path_names: { new: "/:reg_identifier" } do
              get "back/:reg_identifier",
              to: "location_forms#go_back",
              as: "back",
              on: :collection
            end

  resources :register_in_northern_ireland_forms,
            only: [:new, :create],
            path: "register-in-northern-ireland",
            path_names: { new: "/:reg_identifier" } do
              get "back/:reg_identifier",
              to: "register_in_northern_ireland_forms#go_back",
              as: "back",
              on: :collection
            end

  resources :register_in_scotland_forms,
            only: [:new, :create],
            path: "register-in-scotland",
            path_names: { new: "/:reg_identifier" } do
              get "back/:reg_identifier",
              to: "register_in_scotland_forms#go_back",
              as: "back",
              on: :collection
            end

  resources :register_in_wales_forms,
            only: [:new, :create],
            path: "register-in-wales",
            path_names: { new: "/:reg_identifier" } do
              get "back/:reg_identifier",
              to: "register_in_wales_forms#go_back",
              as: "back",
              on: :collection
            end

  resources :business_type_forms,
            only: [:new, :create],
            path: "business-type",
            path_names: { new: "/:reg_identifier" } do
              get "back/:reg_identifier",
              to: "business_type_forms#go_back",
              as: "back",
              on: :collection
            end

  resources :tier_check_forms,
            only: [:new, :create],
            path: "tier-check",
            path_names: { new: "/:reg_identifier" } do
              get "back/:reg_identifier",
              to: "tier_check_forms#go_back",
              as: "back",
              on: :collection
            end

  resources :other_businesses_forms,
            only: [:new, :create],
            path: "other-businesses",
            path_names: { new: "/:reg_identifier" } do
              get "back/:reg_identifier",
              to: "other_businesses_forms#go_back",
              as: "back",
              on: :collection
            end

  resources :service_provided_forms,
            only: [:new, :create],
            path: "service-provided",
            path_names: { new: "/:reg_identifier" } do
              get "back/:reg_identifier",
              to: "service_provided_forms#go_back",
              as: "back",
              on: :collection
            end

  resources :construction_demolition_forms,
            only: [:new, :create],
            path: "construction-demolition",
            path_names: { new: "/:reg_identifier" } do
              get "back/:reg_identifier",
              to: "construction_demolition_forms#go_back",
              as: "back",
              on: :collection
            end

  resources :waste_types_forms,
            only: [:new, :create],
            path: "waste-types",
            path_names: { new: "/:reg_identifier" } do
              get "back/:reg_identifier",
              to: "waste_types_forms#go_back",
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

              get "skip_to_manual_address/:reg_identifier",
              to: "company_postcode_forms#skip_to_manual_address",
              as: "skip_to_manual_address",
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

              get "skip_to_manual_address/:reg_identifier",
              to: "company_address_forms#skip_to_manual_address",
              as: "skip_to_manual_address",
              on: :collection
            end

  resources :company_address_manual_forms,
            only: [:new, :create],
            path: "company-address-manual",
            path_names: { new: "/:reg_identifier" } do
              get "back/:reg_identifier",
              to: "company_address_manual_forms#go_back",
              as: "back",
              on: :collection
            end

  resources :main_people_forms,
            only: [:new, :create],
            path: "main-people",
            path_names: { new: "/:reg_identifier" } do
              get "back/:reg_identifier",
              to: "main_people_forms#go_back",
              as: "back",
              on: :collection

              delete "delete_person/:id",
              to: "main_people_forms#delete_person",
              as: "delete_person",
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

              delete "delete_person/:id",
              to: "conviction_details_forms#delete_person",
              as: "delete_person",
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

  resources :contact_postcode_forms,
            only: [:new, :create],
            path: "contact-postcode",
            path_names: { new: "/:reg_identifier" } do
              get "back/:reg_identifier",
              to: "contact_postcode_forms#go_back",
              as: "back",
              on: :collection

              get "skip_to_manual_address/:reg_identifier",
              to: "contact_postcode_forms#skip_to_manual_address",
              as: "skip_to_manual_address",
              on: :collection
            end

  resources :contact_address_forms,
            only: [:new, :create],
            path: "contact-address",
            path_names: { new: "/:reg_identifier" } do
              get "back/:reg_identifier",
              to: "contact_address_forms#go_back",
              as: "back",
              on: :collection

              get "skip_to_manual_address/:reg_identifier",
              to: "contact_address_forms#skip_to_manual_address",
              as: "skip_to_manual_address",
              on: :collection
            end

  resources :contact_address_manual_forms,
            only: [:new, :create],
            path: "contact-address-manual",
            path_names: { new: "/:reg_identifier" } do
              get "back/:reg_identifier",
              to: "contact_address_manual_forms#go_back",
              as: "back",
              on: :collection
            end

  resources :check_your_answers_forms,
            only: [:new, :create],
            path: "check-your-answers",
            path_names: { new: "/:reg_identifier" } do
              get "back/:reg_identifier",
              to: "check_your_answers_forms#go_back",
              as: "back",
              on: :collection
            end

  resources :declaration_forms,
            only: [:new, :create],
            path: "declaration",
            path_names: { new: "/:reg_identifier" } do
              get "back/:reg_identifier",
              to: "declaration_forms#go_back",
              as: "back",
              on: :collection
            end

  resources :cards_forms,
            only: [:new, :create],
            path: "cards",
            path_names: { new: "/:reg_identifier" } do
              get "back/:reg_identifier",
              to: "cards_forms#go_back",
              as: "back",
              on: :collection
            end

  resources :payment_summary_forms,
            only: [:new, :create],
            path: "payment-summary",
            path_names: { new: "/:reg_identifier" } do
              get "back/:reg_identifier",
              to: "payment_summary_forms#go_back",
              as: "back",
              on: :collection
            end

  resources :worldpay_forms,
            only: [:new, :create],
            path: "worldpay",
            path_names: { new: "/:reg_identifier" } do
              get "success/:reg_identifier",
              to: "worldpay_forms#success",
              as: "success",
              on: :collection

              get "failure/:reg_identifier",
              to: "worldpay_forms#failure",
              as: "failure",
              on: :collection
            end

  resources :bank_transfer_forms,
            only: [:new, :create],
            path: "bank-transfer",
            path_names: { new: "/:reg_identifier" } do
              get "back/:reg_identifier",
              to: "bank_transfer_forms#go_back",
              as: "back",
              on: :collection
            end

  resources :renewal_complete_forms,
            only: [:new, :create],
            path: "renewal-complete",
            path_names: { new: "/:reg_identifier" }

  resources :renewal_received_forms,
            only: [:new, :create],
            path: "renewal-received",
            path_names: { new: "/:reg_identifier" }

  resources :cannot_renew_lower_tier_forms,
            only: [:new, :create],
            path: "cannot-renew-lower-tier",
            path_names: { new: "/:reg_identifier" } do
              get "back/:reg_identifier",
              to: "cannot_renew_lower_tier_forms#go_back",
              as: "back",
              on: :collection
            end

  resources :cannot_renew_type_change_forms,
            only: [:new, :create],
            path: "cannot-renew-type-change",
            path_names: { new: "/:reg_identifier" } do
              get "back/:reg_identifier",
              to: "cannot_renew_type_change_forms#go_back",
              as: "back",
              on: :collection
            end

  resources :cannot_renew_company_no_change_forms,
            only: [:new, :create],
            path: "cannot-renew-company-no-change",
            path_names: { new: "/:reg_identifier" } do
              get "back/:reg_identifier",
              to: "cannot_renew_company_no_change_forms#go_back",
              as: "back",
              on: :collection
            end

  # Static pages with HighVoltage - don't include "/pages/" in the path
  resources :pages, only: [:show], controller: "pages", path: ""
end
