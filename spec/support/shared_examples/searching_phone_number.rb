# frozen_string_literal: true

RSpec.shared_examples "matching and non matching registrations" do
  it "returns a matching record" do
    expect(scope).to include(matching_record)
  end

  it "does not return others" do
    expect(scope).not_to include(non_matching_record)
  end
end

RSpec.shared_examples "searching phone number attribute" do |factory:|
  let(:non_matching_record) do
    create(factory,
           :has_required_data,
           phone_number: "0121117890")
  end

  let(:matching_record) do
    create(factory,
           :has_required_data,
           phone_number: term)
  end

  let(:normal_number) { "01234567890" }
  let(:number_with_spaces) { "012 3456 7890" }
  let(:number_with_dashes) { "012-3456-7890" }
  let(:number_starting_with_44) { "+441234567890" }
  let(:interntational_number) { "+78121234567" }
  let(:number_with_text) { "Landline 01234567890" }

  context "when the number in the database has not got any spaces or dashes and doesn't start in +44" do
    context "and the search term has not got any spaces or dashes and doesn't start in +44" do
      let(:term) { normal_number }
      it_behaves_like "matching and non matching registrations"
    end

    context "but the search term has spaces" do
      let(:term) { number_with_spaces }
      it_behaves_like "matching and non matching registrations"
    end

    context "but the search term has dashes" do
      let(:term) { number_with_dashes }
      it_behaves_like "matching and non matching registrations"
    end

    context "but the search term starts with +44" do
      let(:term) { number_starting_with_44 }
      it_behaves_like "matching and non matching registrations"
    end
  end

  context "when the search term has not got any spaces or dashes and doesn't start in +44" do
    let(:term) { normal_number }
    context "and the database has not got any spaces or dashes and doesn't start in +44" do
      let(:matching_record) do
        create(factory, :has_required_data, phone_number: normal_number)
      end

      it_behaves_like "matching and non matching registrations"
    end

    context "but the database has spaces" do
      let(:matching_record) do
        create(factory, :has_required_data, phone_number: number_with_spaces)
      end
      it_behaves_like "matching and non matching registrations"
    end

    context "but the database has dashes" do
      let(:matching_record) do
        create(factory, :has_required_data, phone_number: number_with_dashes)
      end
      it_behaves_like "matching and non matching registrations"
    end

    context "but the database starts with +44" do
      let(:matching_record) do
        create(factory, :has_required_data, phone_number: number_starting_with_44)
      end
      it_behaves_like "matching and non matching registrations"
    end
  end

  context "when the search term is an international number" do
    context "it only produces exact matches" do
      let(:term) { interntational_number }

      let(:matching_record) do
        create(factory, :has_required_data, phone_number: interntational_number)
      end

      it_behaves_like "matching and non matching registrations"
    end
  end

  context "when the database telephone number has text with it" do
    context "it matches the phone number" do
      let(:term) { normal_number }

      let(:matching_record) do
        create(factory, :has_required_data, phone_number: number_with_text)
      end

      it_behaves_like "matching and non matching registrations"
    end
  end
end
