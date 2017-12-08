require "rails_helper"

RSpec.describe "RenewalStartForms", type: :request do
  describe "GET new_renewal_start_form_path" do
    context "when a user is signed in" do
      before(:each) do
        user = create(:user)
        sign_in(user)
      end

      context "when a matching registration exists" do
        context "when no renewal is in progress for the registration" do
          let(:registration) { create(:registration, :has_required_data) }

          it "returns a success response" do
            get new_renewal_start_form_path(registration[:reg_identifier])
            expect(response).to have_http_status(200)
          end
        end

        context "when a renewal is already in progress" do
          it "says no" do
            # TODO
          end
        end
      end

      context "when no matching registration exists" do
        it "says no" do
          # TODO
        end
      end
    end

    context "when a user is not signed in" do
      before(:each) do
        user = create(:user)
        sign_out(user)
      end

      it "returns a 302 response" do
        get new_renewal_start_form_path("foo")
        expect(response).to have_http_status(302)
      end

      it "redirects to the sign in page" do
        get new_renewal_start_form_path("foo")
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "POST renewal_start_forms_path" do
    context "when a user is signed in" do
      before(:each) do
        user = create(:user)
        sign_in(user)
      end

      context "when a matching registration exists" do
        let(:registration) { create(:registration, :has_required_data) }

        context "when no renewal is in progress for the registration" do
          context "when valid params are submitted" do
            let(:valid_params) { { reg_identifier: registration.reg_identifier } }

            it "creates a new transient registration" do
              expected_tr_count = TransientRegistration.count + 1
              post renewal_start_forms_path, renewal_start_form: valid_params
              updated_tr_count = TransientRegistration.count

              expect(expected_tr_count).to eq(updated_tr_count)
            end

            it "creates a transient registration with correct data" do
              post renewal_start_forms_path, renewal_start_form: valid_params
              transient_registration = TransientRegistration.where(reg_identifier: registration.reg_identifier).first

              expect(transient_registration.reg_identifier).to eq(valid_params[:reg_identifier])
            end

            it "returns a 302 response" do
              post renewal_start_forms_path, renewal_start_form: valid_params
              expect(response).to have_http_status(302)
            end

            it "redirects to the root path" do
              post renewal_start_forms_path, renewal_start_form: valid_params
              expect(response).to redirect_to(root_path)
            end
          end

          context "when invalid params are submitted" do
            let(:invalid_params) { { reg_identifier: "foo" } }

            it "does not create a new transient registration" do
              original_tr_count = TransientRegistration.count
              post renewal_start_forms_path, renewal_start_form: invalid_params
              updated_tr_count = TransientRegistration.count
              expect(original_tr_count).to eq(updated_tr_count)
            end
          end
        end

        context "when a renewal is already in progress" do
          let(:valid_params) { { reg_identifier: registration.reg_identifier } }

          before(:each) do
            create(:transient_registration, :has_required_data, reg_identifier: registration.reg_identifier)
          end

          it "redirects to an error page" do
            post renewal_start_forms_path, renewal_start_form: valid_params
            # TODO: Add error page
            # expect(response).to redirect_to(error_path)
          end

          it "does not create a new transient registration" do
            original_tr_count = TransientRegistration.count
            post renewal_start_forms_path, renewal_start_form: valid_params
            updated_tr_count = TransientRegistration.count

            expect(original_tr_count).to eq(updated_tr_count)
          end
        end
      end

      context "when no matching registration exists" do
        let(:valid_params) { { reg_identifier: "foo" } }

        it "redirects to an error page" do
          post renewal_start_forms_path, renewal_start_form: valid_params
          # TODO: Add error page
          # expect(response).to redirect_to(error_path)
        end

        it "does not create a new transient registration" do
          original_tr_count = TransientRegistration.count
          post renewal_start_forms_path, renewal_start_form: valid_params
          updated_tr_count = TransientRegistration.count

          expect(original_tr_count).to eq(updated_tr_count)
        end
      end
    end

    context "when a user is not signed in" do
      let(:registration) { create(:registration, :has_required_data) }
      let(:valid_params) { { reg_identifier: registration[:reg_identifier] } }

      before(:each) do
        user = create(:user)
        sign_out(user)
      end

      it "returns a 302 response" do
        post renewal_start_forms_path, renewal_start_form: valid_params
        expect(response).to have_http_status(302)
      end

      it "redirects to the sign in page" do
        post renewal_start_forms_path, renewal_start_form: valid_params
        expect(response).to redirect_to(new_user_session_path)
      end

      it "does not create a new transient registration" do
        original_tr_count = TransientRegistration.count
        post renewal_start_forms_path, renewal_start_form: valid_params
        updated_tr_count = TransientRegistration.count
        expect(original_tr_count).to eq(updated_tr_count)
      end
    end
  end
end
