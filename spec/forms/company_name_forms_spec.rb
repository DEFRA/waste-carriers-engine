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
    let(:company_name_form) { build(:company_name_form, :has_required_data) }

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
end
