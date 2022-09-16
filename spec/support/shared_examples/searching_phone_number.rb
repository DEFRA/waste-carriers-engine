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
  let(:normal_number) { "01234567890" }
  let(:number_with_spaces) { "012 3456 7890" }
  let(:number_with_dashes) { "012-3456-7890" }
  let(:number_starting_with_44) { "+441234567890" }
  let(:international_number) { "+78121234567" }
  let(:number_with_text) { "Landline 01234567890" }

  # Use "let!" to ensure these are instantiated in the DB in all cases
  let!(:non_matching_record) { create(factory, :has_required_data, phone_number: "0121117890") }
  let!(:matching_record) { create(factory, :has_required_data, phone_number: matching_phone_number) }

  context "when the number in the database has not got any spaces or dashes and doesn't start in +44" do
    let(:matching_phone_number) { normal_number }

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

      context "and the search term is short" do
        let(:term) { "+44 12345678" }

        it "returns no matches with no error" do
          expect { scope }.not_to raise_error
          expect(scope).to be_empty
        end
      end
    end

    context "when the search term is a partial number" do
      let(:term) { normal_number.slice(0..-3) }

      it "does not match any registrations" do
        expect(scope).to be_empty
      end
    end
  end

  context "when the search term has not got any spaces or dashes and doesn't start in +44" do
    let(:term) { normal_number }

    context "and the number in the database has spaces" do
      let(:matching_phone_number) { number_with_spaces }

      it_behaves_like "matching and non matching registrations"
    end

    context "and the number in the database has dashes" do
      let(:matching_phone_number) { number_with_dashes }

      it_behaves_like "matching and non matching registrations"
    end

    context "and the number in the database starts with +44" do
      let(:matching_phone_number) { number_starting_with_44 }

      it_behaves_like "matching and non matching registrations"
    end
  end

  context "when the search term is in international number format" do
    let(:term) { international_number }

    context "and the number in the database is in international number format" do
      let(:matching_phone_number) { international_number }

      it_behaves_like "matching and non matching registrations"
    end

    context "and the number in the database is not in international number format" do
      let(:matching_phone_number) { normal_number }

      it "does not match any registrations" do
        expect(scope).to be_empty
      end
    end
  end

  context "when the number in the database includes text" do
    let(:matching_phone_number) { number_with_text }

    context "with a standard format search term" do
      let(:term) { normal_number }

      it_behaves_like "matching and non matching registrations"
    end
  end
end
