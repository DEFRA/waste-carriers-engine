# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
WasteCarriersEngine::Engine.routes.draw do
  resources :start_forms,
            only: %i[new create],
            path: "start",
            path_names: { new: "" },
            constraints: ->(_request) { WasteCarriersEngine::FeatureToggle.active?(:new_registration) }

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

    # Order copy cards flow
    resources :copy_cards_forms,
              only: %i[new create],
              path: "order-copy-cards",
              path_names: { new: "" }

    resources :copy_cards_payment_forms,
              only: %i[new create],
              path: "order-copy-cards-payment",
              path_names: { new: "" } do
                get "back",
                    to: "copy_cards_payment_forms#go_back",
                    as: "back",
                    on: :collection
              end

    resources :copy_cards_bank_transfer_forms,
              only: %i[new create],
              path: "order-copy-cards-bank-transfer",
              path_names: { new: "" }

    resources :copy_cards_order_completed_forms,
              only: %i[new create],
              path: "order-copy-cards-complete",
              path_names: { new: "" }
    # End of order copy cards flow

    # Ceased or revoked flow
    resources :cease_or_revoke_forms,
              only: %i[new create],
              path: "cease-or-revoke",
              path_names: { new: "" }

    resources :ceased_or_revoked_confirm_forms,
              only: %i[new create],
              path: "ceased-or-revoked-confirm",
              path_names: { new: "" } do
                get "back",
                    to: "ceased_or_revoked_confirm_forms#go_back",
                    as: "back",
                    on: :collection
              end
    # End of ceased or revoked flow

    # Edit flow
    resources :edit_forms,
              only: %i[new create],
              path: "edit",
              path_names: { new: "" } do
                get "cbd-type",
                    to: "edit_forms#edit_cbd_type",
                    as: "cbd_type",
                    on: :collection

                get "company-name",
                    to: "edit_forms#edit_company_name",
                    as: "company_name",
                    on: :collection

                get "main-people",
                    to: "edit_forms#edit_main_people",
                    as: "main_people",
                    on: :collection

                get "company-address",
                    to: "edit_forms#edit_company_address",
                    as: "company_address",
                    on: :collection

                get "contact-name",
                    to: "edit_forms#edit_contact_name",
                    as: "contact_name",
                    on: :collection

                get "contact-phone",
                    to: "edit_forms#edit_contact_phone",
                    as: "contact_phone",
                    on: :collection

                get "contact-email",
                    to: "edit_forms#edit_contact_email",
                    as: "contact_email",
                    on: :collection

                get "contact-address",
                    to: "edit_forms#edit_contact_address",
                    as: "contact_address",
                    on: :collection

                get "contact-address-reuse",
                    to: "edit_forms#edit_contact_address_reuse",
                    as: "contact_address_reuse",
                    on: :collection

                get "cancel",
                    to: "edit_forms#cancel",
                    as: "cancel",
                    on: :collection
              end

    resources :edit_payment_summary_forms,
              only: %i[new create],
              path: "edit-payment",
              path_names: { new: "" } do
                get "back",
                    to: "edit_payment_summary_forms#go_back",
                    as: "back",
                    on: :collection
              end

    resources :edit_bank_transfer_forms,
              only: %i[new create],
              path: "edit-bank-transfer",
              path_names: { new: "" }

    resources :edit_complete_forms,
              only: %i[new create],
              path: "edit-complete",
              path_names: { new: "" }

    resources :confirm_edit_cancelled_forms,
              only: %i[new create],
              path: "confirm-edit-cancelled",
              path_names: { new: "" }

    resources :edit_cancelled_forms,
              only: %i[new create],
              path: "edit-cancelled",
              path_names: { new: "" }
    # End of edit flow

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
