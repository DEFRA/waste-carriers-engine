require "rails_helper"

RSpec.describe CompanyNameForm, type: :model do
  describe "#submit" do
    context "when the form is valid" do
      let(:company_name_form) { build(:company_name_form, :has_required_data) }
      let(:valid_params) do
        { reg_identifier: company_name_form.reg_identifier, company_name: company_name_form.company_name }
      end

      it "should submit" do
        expect(company_name_form.submit(valid_params)).to eq(true)
      end
    end

    context "when the form is not valid" do
      let(:company_name_form) { build(:company_name_form, :has_required_data) }
      let(:invalid_params) { { reg_identifier: "foo" } }

      it "should not submit" do
        expect(company_name_form.submit(invalid_params)).to eq(false)
      end
    end
  end


  context "when a valid transient registration exists" do
    let(:transient_registration) do
      create(:transient_registration,
             :has_required_data,
             workflow_state: "company_name_form")
    end
    # Don't use FactoryBot for this as we need to make sure it initializes with a specific object
    let(:company_name_form) { CompanyNameForm.new(transient_registration) }

    describe "#reg_identifier" do
      context "when a reg_identifier meets the requirements" do
        before(:each) do
          company_name_form.reg_identifier = transient_registration.reg_identifier
        end

        it "is valid" do
          expect(company_name_form).to be_valid
        end
      end

      context "when a reg_identifier is blank" do
        before(:each) do
          company_name_form.reg_identifier = ""
        end

        it "is not valid" do
          expect(company_name_form).to_not be_valid
        end
      end
    end

    describe "#company_name" do
      context "when a company_name meets the requirements" do
        it "is valid" do
          expect(company_name_form).to be_valid
        end
      end

      context "when a company_name is blank" do
        before(:each) { company_name_form.company_name = "" }

        it "is not valid" do
          expect(company_name_form).to_not be_valid
        end
      end

      context "when a company name is too long" do
        before(:each) { company_name_form.company_name = "ak67inm5ijij85w3a7gck67iloe2k98zyk01607xbhfqzznr4kbl5tuypqlbrpdvwqcup8ij9o2b0ryquhdmv5716s9zia3vz184g5vkhnk8869whwulmkqd47tqxveifrsg4wxpi0dbygo42k1ujdj8w4we2uvfvoamovk0u8ru5bk5esrxwxdue8sh7e03e3popgl2yzjvs5vk49xt5qtxaijdafdnlgc468jj4k21g3jumtsxc9nup8bgu83viakj0x6c47r7zfzxrr2nl3rn47v86odk6ra0e0dic7g7" }

        it "is not valid" do
          expect(company_name_form).to_not be_valid
        end
      end
    end
  end

  describe "#transient_registration" do
    context "when the transient registration is invalid" do
      let(:transient_registration) do
        build(:transient_registration,
              workflow_state: "company_name_form")
      end
      # Don't use FactoryBot for this as we need to make sure it initializes with a specific object
      let(:company_name_form) { CompanyNameForm.new(transient_registration) }

      before(:each) do
        # Make reg_identifier valid for the form, but not the transient object
        company_name_form.reg_identifier = transient_registration.reg_identifier
        transient_registration.reg_identifier = "foo"
      end

      it "is not valid" do
        expect(company_name_form).to_not be_valid
      end

      it "inherits the errors from the transient_registration" do
        company_name_form.valid?
        expect(company_name_form.errors[:base]).to include(I18n.t("mongoid.errors.models.transient_registration.attributes.reg_identifier.invalid_format"))
      end
    end
  end
end
