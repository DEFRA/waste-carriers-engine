# frozen_string_literal: true

RSpec.shared_examples "valid only if company_name is not required" do
  context "when the company name is not required" do
    before { allow(form.transient_registration).to receive(:company_name_required?).and_return(false) }

    it "is valid" do
      expect(form).to be_valid
    end
  end

  context "when the company name is required" do
    before { allow(form.transient_registration).to receive(:company_name_required?).and_return(true) }

    it "is not valid" do
      expect(form).to_not be_valid
    end
  end
end

# Tests for fields using the CompanyNameValidator
RSpec.shared_examples "validate company_name" do |form_factory|
  context "when a valid transient registration exists" do
    let(:form) { build(form_factory, :has_required_data) }

    context "when a company_name meets the requirements" do
      it "is valid" do
        expect(form).to be_valid
      end
    end

    context "when a company_name is blank" do
      before { form.transient_registration.company_name = "" }

      it_behaves_like "valid only if company_name is not required"
    end

    context "when a company_name is nil" do
      before { form.transient_registration.company_name = nil }

      it_behaves_like "valid only if company_name is not required"
    end

    context "when a company name is too long" do
      before do
        form.transient_registration.company_name = "ak67inm5ijij85w3a7gck67iloe2k98zyk01607xbhfqzznr4kbl5tuypqlbrpdvwqcup8ij9o2b0ryquhdmv5716s9zia3vz184g5vkhnk8869whwulmkqd47tqxveifrsg4wxpi0dbygo42k1ujdj8w4we2uvfvoamovk0u8ru5bk5esrxwxdue8sh7e03e3popgl2yzjvs5vk49xt5qtxaijdafdnlgc468jj4k21g3jumtsxc9nup8bgu83viakj0x6c47r7zfzxrr2nl3rn47v86odk6ra0e0dic7g7"
      end

      it "is not valid" do
        expect(form).to_not be_valid
      end
    end
  end
end
