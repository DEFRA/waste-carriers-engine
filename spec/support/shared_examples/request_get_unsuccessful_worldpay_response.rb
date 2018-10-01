RSpec.shared_examples "GET unsuccessful Worldpay response" do |action|
  context "when a valid user is signed in" do
    let(:user) { create(:user) }
    before(:each) do
      sign_in(user)
    end

    context "when a valid transient registration exists" do
      let(:transient_registration) do
        create(:transient_registration,
               :has_required_data,
               :has_addresses,
               :has_conviction_search_result,
               :has_key_people,
               account_email: user.email,
               workflow_state: "worldpay_form")
      end
      let(:reg_id) { transient_registration[:reg_identifier] }

      before do
        WasteCarriersEngine::FinanceDetails.new_finance_details(transient_registration, :worldpay, user)
      end

      let(:order) do
        transient_registration.finance_details.orders.first
      end

      let(:params) do
        {
          orderKey: "#{Rails.configuration.worldpay_admin_code}^#{Rails.configuration.worldpay_merchantcode}^#{order.order_code}",
          reg_identifier: reg_id
        }
      end

      let(:validation_action) { "valid_#{action}?".to_sym }
      let(:path) do
        path_route = "#{action}_worldpay_forms_path".to_sym
        self.public_send(path_route, reg_id)
      end

      context "when the params are valid" do
        before do
          allow_any_instance_of(WasteCarriersEngine::WorldpayService).to receive(validation_action).and_return(true)
        end

        it "redirects to payment_summary_form" do
          get path, params
          expect(response).to redirect_to(new_payment_summary_form_path(reg_id))
        end
      end

      context "when the params are not valid" do
        before do
          allow_any_instance_of(WasteCarriersEngine::WorldpayService).to receive(validation_action).and_return(false)
        end

        it "redirects to payment_summary_form" do
          get path, params
          expect(response).to redirect_to(new_payment_summary_form_path(reg_id))
        end
      end
    end
  end
end
