# frozen_string_literal: true

RSpec.shared_examples "GET unsuccessful Worldpay response" do |action|
  context "when a valid user is signed in" do
    let(:user) { create(:user) }

    before do
      sign_in(user)
    end

    context "when a valid transient registration exists" do
      let(:transient_registration) do
        create(:renewing_registration,
               :has_required_data,
               :has_addresses,
               :has_conviction_search_result,
               :has_key_people,
               account_email: user.email,
               workflow_state: "worldpay_form",
               workflow_history: ["payment_summary_form"])
      end
      let(:order) do
        transient_registration.finance_details.orders.first
      end
      let(:params) do
        {
          orderKey: "#{Rails.configuration.worldpay_admin_code}^#{Rails.configuration.worldpay_merchantcode}^#{order.order_code}"
        }
      end
      let(:validation_action) { "valid_#{action}?".to_sym }
      let(:path) do
        path_route = "#{action}_worldpay_forms_path".to_sym
        public_send(path_route, token)
      end
      let(:token) { transient_registration.token }

      let(:worldpay_service_instance) { instance_double(WasteCarriersEngine::WorldpayService) }

      before do
        allow(WasteCarriersEngine::WorldpayService).to receive(:new).and_return(worldpay_service_instance)
        transient_registration.prepare_for_payment(:worldpay, user)
      end

      context "when the params are valid" do
        before do
          allow(worldpay_service_instance).to receive(validation_action).and_return(true)
        end

        it "redirects to payment_summary_form" do
          get path, params: params
          expect(response).to redirect_to(new_payment_summary_form_path(token))
        end
      end

      context "when the params are not valid" do
        before do
          allow(worldpay_service_instance).to receive(validation_action).and_return(false)
        end

        it "redirects to payment_summary_form" do
          get path, params: params
          expect(response).to redirect_to(new_payment_summary_form_path(token))
        end
      end
    end
  end
end
