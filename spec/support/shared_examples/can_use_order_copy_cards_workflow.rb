# frozen_string_literal: true

RSpec.shared_examples "Can use order copy cards workflow" do
  describe "workflow_state" do
    context "when a OrderCopyCardsRegistration is created" do
      it "has the state :copy_cards_form" do
        expect(subject).to have_state(:copy_cards_form)
      end
    end

    context "transitions" do
      context "on next" do
        it "can transition from a :copy_cards_form state to a :copy_cards_payment_form" do
          subject.workflow_state = :copy_cards_form

          subject.next

          expect(subject.workflow_state).to eq("copy_cards_payment_form")
        end

        context "when the method is paying by card" do
          it "can transition from :copy_cards_payment_form to :worldpay_form" do
            subject.temp_payment_method = "card"
            subject.workflow_state = :copy_cards_payment_form

            subject.next

            expect(subject.workflow_state).to eq("worldpay_form")
          end
        end

        context "when the method is not paying by card" do
          it "can transition from :copy_cards_payment_form to :bank_transfer_form" do
            subject.temp_payment_method = "foo"
            subject.workflow_state = :copy_cards_payment_form

            subject.next

            expect(subject.workflow_state).to eq("bank_transfer_form")
          end
        end
      end

      context "on back" do
        it "can transition from a :copy_cards_payment_form state to a :copy_cards_form" do
          subject.workflow_state = :copy_cards_payment_form

          subject.back

          expect(subject.workflow_state).to eq("copy_cards_form")
        end

        it "can transition from a :worldpay_form state to a :copy_cards_payment_form" do
          subject.workflow_state = :worldpay_form

          subject.back

          expect(subject.workflow_state).to eq("copy_cards_payment_form")
        end

        it "can transition from a :bank_transfer_form state to a :copy_cards_payment_form" do
          subject.workflow_state = :bank_transfer_form

          subject.back

          expect(subject.workflow_state).to eq("copy_cards_payment_form")
        end
      end
    end
  end
end
