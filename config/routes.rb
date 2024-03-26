# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
WasteCarriersEngine::Engine.routes.draw do
  resources :start_forms,
            only: %i[new create],
            path: "start",
            path_names: { new: "" }

  get "transient-registration/:token/destroy",
      to: "transient_registrations#destroy",
      as: "delete_transient_registration"

  scope "/:token" do
    # New registration flow
    resources :renew_registration_forms,
              only: %i[new create],
              path: "renew-registration",
              path_names: { new: "" }

    resources :renewal_stop_forms,
              only: %i[new],
              path: "renewal-stop",
              path_names: { new: "" }

    resources :your_tier_forms,
              only: %i[new create],
              path: "your-tier",
              path_names: { new: "" } do
                get "back",
                    to: "your_tier_forms#go_back",
                    as: "back",
                    on: :collection
              end

    resources :check_your_tier_forms,
              only: %i[new create],
              path: "check-your-tier",
              path_names: { new: "" }

    resources :registration_received_pending_payment_forms,
              only: :new,
              path: "registration-received-pending-payment",
              path_names: { new: "" }

    resources :registration_received_pending_govpay_payment_forms,
              only: :new,
              path: "registration-received-pending-govpay-payment",
              path_names: { new: "" }

    resources :registration_completed_forms,
              only: :new,
              path: "registration-completed",
              path_names: { new: "" }

    resources :registration_received_pending_conviction_forms,
              only: :new,
              path: "registration-received",
              path_names: { new: "" }
    # End of new registration flow

    # Deregistration flow
    resources :deregistration_confirmation_forms,
              only: %i[new create],
              path: "deregistration-confirmation",
              path_names: { new: "" }

    resources :deregistration_complete_forms,
              only: %i[new create],
              path: "deregistration-complete",
              path_names: { new: "" }
    # End of deregistration flow

    resources :renewal_start_forms,
              only: %i[new create],
              path: "renew",
              path_names: { new: "" }

    resources :location_forms,
              only: %i[new create],
              path: "location",
              path_names: { new: "" }

    resources :must_register_in_northern_ireland_forms,
              only: %i[new create],
              path: "must-register-in-northern-ireland",
              path_names: { new: "" }

    resources :register_in_northern_ireland_forms,
              only: %i[new create],
              path: "register-in-northern-ireland",
              path_names: { new: "" }

    resources :must_register_in_scotland_forms,
              only: %i[new create],
              path: "must-register-in-scotland",
              path_names: { new: "" }

    resources :register_in_scotland_forms,
              only: %i[new create],
              path: "register-in-scotland",
              path_names: { new: "" }

    resources :must_register_in_wales_forms,
              only: %i[new create],
              path: "must-register-in-wales",
              path_names: { new: "" }

    resources :register_in_wales_forms,
              only: %i[new create],
              path: "register-in-wales",
              path_names: { new: "" }

    resources :business_type_forms,
              only: %i[new create],
              path: "business-type",
              path_names: { new: "" }

    resources :other_businesses_forms,
              only: %i[new create],
              path: "other-businesses",
              path_names: { new: "" }

    resources :service_provided_forms,
              only: %i[new create],
              path: "service-provided",
              path_names: { new: "" }

    resources :construction_demolition_forms,
              only: %i[new create],
              path: "construction-demolition",
              path_names: { new: "" }

    resources :waste_types_forms,
              only: %i[new create],
              path: "waste-types",
              path_names: { new: "" }

    resources :cbd_type_forms,
              only: %i[new create],
              path: "cbd-type",
              path_names: { new: "" }

    resources :renewal_information_forms,
              only: %i[new create],
              path: "renewal-information",
              path_names: { new: "" }

    resources :registration_number_forms,
              only: %i[new create],
              path: "registration-number",
              path_names: { new: "" }

    resources :check_registered_company_name_forms,
              only: %i[new create],
              path: "check-registered-company-name",
              path_names: { new: "" }

    resources :incorrect_company_forms,
              only: %i[new create],
              path: "incorrect-company",
              path_names: { new: "" }

    resources :invalid_company_status_forms,
              only: %i[new create],
              path: "invalid-company-status",
              path_names: { new: "" }

    resources :use_trading_name_forms,
              only: %i[new create],
              path: "use-trading-name",
              path_names: { new: "" }

    resources :company_name_forms,
              only: %i[new create],
              path: "company-name",
              path_names: { new: "" }

    resources :company_postcode_forms,
              only: %i[new create],
              path: "company-postcode",
              path_names: { new: "" } do
                get "skip_to_manual_address",
                    to: "company_postcode_forms#skip_to_manual_address",
                    as: "skip_to_manual_address",
                    on: :collection
              end

    resources :company_address_forms,
              only: %i[new create],
              path: "company-address",
              path_names: { new: "" } do
                get "skip_to_manual_address",
                    to: "company_address_forms#skip_to_manual_address",
                    as: "skip_to_manual_address",
                    on: :collection
              end

    resources :company_address_manual_forms,
              only: %i[new create],
              path: "company-address-manual",
              path_names: { new: "" }

    resources :main_people_forms,
              only: %i[new create],
              path: "main-people",
              path_names: { new: "" } do
                delete "delete_person/:id",
                       to: "main_people_forms#delete_person",
                       as: "delete_person",
                       on: :collection
              end

    resources :declare_convictions_forms,
              only: %i[new create],
              path: "declare-convictions",
              path_names: { new: "" }

    resources :conviction_details_forms,
              only: %i[new create],
              path: "conviction-details",
              path_names: { new: "" } do
                delete "delete_person/:id",
                       to: "conviction_details_forms#delete_person",
                       as: "delete_person",
                       on: :collection
              end

    resources :contact_name_forms,
              only: %i[new create],
              path: "contact-name",
              path_names: { new: "" }

    resources :contact_phone_forms,
              only: %i[new create],
              path: "contact-phone",
              path_names: { new: "" }

    resources :contact_email_forms,
              only: %i[new create],
              path: "contact-email",
              path_names: { new: "" }

    resources :contact_postcode_forms,
              only: %i[new create],
              path: "contact-postcode",
              path_names: { new: "" } do
                get "skip_to_manual_address",
                    to: "contact_postcode_forms#skip_to_manual_address",
                    as: "skip_to_manual_address",
                    on: :collection
              end

    resources :contact_address_forms,
              only: %i[new create],
              path: "contact-address",
              path_names: { new: "" } do
                get "skip_to_manual_address",
                    to: "contact_address_forms#skip_to_manual_address",
                    as: "skip_to_manual_address",
                    on: :collection
              end

    resources :contact_address_manual_forms,
              only: %i[new create],
              path: "contact-address-manual",
              path_names: { new: "" }

    resources :contact_address_reuse_forms,
              only: %i[new create],
              path: "contact-address-reuse",
              path_names: { new: "" }

    resources :check_your_answers_forms,
              only: %i[new create],
              path: "check-your-answers",
              path_names: { new: "" }

    resources :declaration_forms,
              only: %i[new create],
              path: "declaration",
              path_names: { new: "" }

    resources :cards_forms,
              only: %i[new create],
              path: "cards",
              path_names: { new: "" }

    resources :payment_summary_forms,
              only: %i[new create],
              path: "payment-summary",
              path_names: { new: "" }

    resources :payment_method_confirmation_forms,
              only: %i[new create],
              path: "payment-method-confirmation",
              path_names: { new: "" }

    resources :govpay_forms,
              only: %i[new create],
              path: "govpay",
              path_names: { new: "" } do
                get "payment_callback/:uuid",
                    to: "govpay_forms#payment_callback",
                    as: "payment_callback",
                    on: :collection
              end

    resources :confirm_bank_transfer_forms,
              only: %i[new create],
              path: "confirm-bank-transfer",
              path_names: { new: "" }

    resources :renewal_complete_forms,
              only: %i[new create],
              path: "renewal-complete",
              path_names: { new: "" }

    resources :renewal_received_pending_conviction_forms,
              only: %i[new create],
              path: "renewal-received",
              path_names: { new: "" }

    resources :renewal_received_pending_payment_forms,
              only: %i[new create],
              path: "renewal-received-pending-payment",
              path_names: { new: "" }

    resources :renewal_received_pending_govpay_payment_forms,
              only: %i[new create],
              path: "renewal-received-pending-govpay-payment",
              path_names: { new: "" }

    resources :cannot_renew_type_change_forms,
              only: %i[new create],
              path: "cannot-renew-type-change",
              path_names: { new: "" }

    get "/back", to: "forms#go_back", as: "go_back_forms"
  end

  get ":reg_identifier/certificate", to: "certificates#show", as: "certificate"
  get ":reg_identifier/pdf_certificate", to: "certificates#pdf", as: "pdf_certificate"
  get ":reg_identifier/certificate_confirm_email", to: "certificates#confirm_email", as: "certificate_confirm_email"
  post ":reg_identifier/certificate_process_email", to: "certificates#process_email", as: "certificate_process_email"
  get ":reg_identifier/certificate_renew_token", to: "certificates#renew_token", as: "certificate_renew_token"
  post ":reg_identifier/certificate_reset_token", to: "certificates#reset_token", as: "certificate_reset_token"
  get ":reg_identifier/certificate_renewal_sent", to: "certificates#renewal_sent", as: "certificate_renewal_sent"

  get "/unsubscribe/:unsubscribe_token", to: "unsubscribe#unsubscribe", as: "unsubscribe"
  get "/unsubscribe_successful", to: "unsubscribe#unsubscribe_successful", as: "unsubscribe_successful"
  get "/unsubscribe_failed", to: "unsubscribe#unsubscribe_failed", as: "unsubscribe_failed"

  mount DefraRubyEmail::Engine => "/email"

  # See http://patrickperey.com/railscast-053-handling-exceptions/
  get "(errors)/:status",
      to: "errors#show",
      constraints: { status: /\d{3}/ },
      as: "error"

  # Renew via magic link token
  get "/renew/:token",
      to: "renews#new",
      as: "renew"

  # Deregister via magic link token
  get "/deregister/:token",
      to: "deregisters#new",
      as: "deregister"

  # Static pages with HighVoltage
  resources :pages, only: [:show], controller: "pages"
end
# rubocop:enable Metrics/BlockLength
