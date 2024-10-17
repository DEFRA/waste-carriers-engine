# frozen_string_literal: true

require "rails_helper"
require "faker"

module WasteCarriersEngine
  RSpec.describe RegistrationCompletionService do
    describe ".run" do
      subject(:complete_registration) { described_class.run(transient_registration) }

      shared_examples "specs for all transient registration types" do

        it { expect(complete_registration.contact_address).to be_present }
        it { expect(complete_registration.finance_details).to be_present }
        it { expect(complete_registration.finance_details.orders.count).to eq(1) }
        it { expect(complete_registration.key_people).to match_array(transient_registration.key_people.where(person_type: "KEY")) }
        it { expect(complete_registration.location).to be_present }
        it { expect(complete_registration.main_people).to match_array(transient_registration.main_people) }
        it { expect(complete_registration.metaData.route).to be_present }
        it { expect(complete_registration.metaData.date_registered).to be_present }
        it { expect(complete_registration.reg_identifier).to be_present }
        it { expect(complete_registration.metaData.certificate_version).to eq(1) }
        it { expect(complete_registration.metaData.certificate_version_history.length).to eq(1) }

        context "when all temporary attributes are populated" do
          before do
            TransientRegistration.fields.keys.select { |t| t.start_with?("temp_") }.each do |temp_field|
              unless transient_registration.send(temp_field).present?
                transient_registration.send("#{temp_field}=", "yes")
              end
            end
            transient_registration.save!
          end

          it "does not raise an exception" do
            expect { described_class.run(transient_registration) }.not_to raise_error
          end
        end

        it "deletes the transient registration" do
          token = transient_registration.token

          described_class.run(transient_registration)

          new_registration_scope = WasteCarriersEngine::NewRegistration.where(token: token)

          expect(new_registration_scope.to_a).to be_empty
        end
      end

      context "when the registration is lower tier" do
        let(:transient_registration) { create(:new_registration, :has_required_lower_tier_data) }

        it_behaves_like "specs for all transient registration types"

        it { expect(complete_registration.expires_on).to be_nil }
        it { expect(complete_registration).to be_active }
        it { expect(complete_registration.finance_details.payments.count).to eq(0) }
        it { expect(complete_registration.finance_details.balance).to eq(0) }

        it "does not set conviction search result and sign offs" do
          transient_registration.conviction_search_result = { match_result: "NO", confirmed: "no" }
          transient_registration.conviction_sign_offs = [ConvictionSignOff.new]
          registration = described_class.run(transient_registration)

          expect(registration.conviction_search_result).to be_nil
          expect(registration.conviction_sign_offs).to be_empty
        end
      end

      context "when the registration is upper tier" do
        let(:transient_registration) do
          build(:new_registration, :has_required_data)
        end

        before { transient_registration.finance_details.payments << build(:payment) }

        it_behaves_like "specs for all transient registration types"

        it "generates a new registration" do
          expect { complete_registration }.to change(WasteCarriersEngine::Registration, :count).by(1)
        end

        it { expect(complete_registration.registered_address).to eq(transient_registration.registered_address) }
        it { expect(complete_registration.expires_on).to be_present }
        it { expect(complete_registration.finance_details.orders.count).to eq(1) }
        it { expect(complete_registration.finance_details.payments.count).to eq(1) }
        it { expect(complete_registration).to be_pending }

        context "when there are declared convictions" do
          before do
            transient_registration.declared_convictions = "yes"
            ConvictionDataService.run(transient_registration)
          end

          # it { expect(complete_registration.declared_convictions).to eq "yes" }

          context "when there is a conviction check match against the business" do
            before do
              transient_registration.conviction_search_result = build(:conviction_search_result, :match_result_yes)
              transient_registration.key_people = [build(:key_person, :unmatched_conviction_search_result)]
            end

            it { expect(complete_registration.conviction_sign_offs).to exist }
            it { expect(complete_registration.key_people.first.conviction_search_result.match_result).to eq "NO" }
          end

          context "when there is a conviction check match against a person" do
            before do
              transient_registration.conviction_search_result = build(:conviction_search_result, :match_result_no)
              transient_registration.key_people = [build(:key_person, :matched_conviction_search_result)]
            end

            it { expect(complete_registration.reload.conviction_sign_offs).to exist }
            it { expect(complete_registration.key_people.first.conviction_search_result.match_result).to eq "YES" }
          end
        end

        context "when the balance has been cleared and there are no pending convictions checks" do
          let(:finance_details) { build(:finance_details, :has_paid_order_and_payment) }

          before do
            transient_registration.finance_details = finance_details
            transient_registration.save
          end

          it "activates the registration" do
            expect(complete_registration).to be_active
          end

          it "creates the correct number of order item logs" do
            expect { complete_registration }.to change(OrderItemLog, :count)
              .from(0)
              .to(transient_registration.finance_details.orders.sum { |o| o.order_items.length })
          end

          context "with multiple orders and multiple order items" do
            # Allow for multiple orders per registration, multiple order items per order and a variable quantity per order item
            before do
              orders = []
              order_count = Faker::Number.between(from: 1, to: 3)
              order_count.times do
                order = build(:order)
                order_item_count = Faker::Number.between(from: 1, to: 5)
                order.order_items = build_list(
                  :order_item,
                  order_item_count,
                  quantity: Faker::Number.between(from: 1, to: 7),
                  type: OrderItem::TYPES.values[rand(OrderItem::TYPES.size)]
                )
                orders << order
              end
              transient_registration.finance_details.orders = orders
            end

            it "creates the correct number of order item logs" do
              expect { complete_registration }.to change(OrderItemLog, :count)
                .from(0)
                .to(transient_registration.finance_details.orders.sum { |o| o.order_items.length })
            end

            it "captures the order item types correctly" do
              order_items_by_type = {}
              complete_registration.finance_details.orders.map do |o|
                o.order_items.each do |oi|
                  order_items_by_type[oi["type"]] ||= 0
                  order_items_by_type[oi["type"]] += 1
                end
              end
              order_items_by_type.each do |k, _v|
                expect(OrderItemLog.where(type: k).count).to eq order_items_by_type[k]
              end
            end

            it "stores the registration activation date for all order items" do
              expect(OrderItemLog.where(activated_at: complete_registration.metaData.dateActivated).count).to eq OrderItemLog.count
            end
          end
        end

        context "when there is a pending govpay balance" do
          let(:finance_details) { build(:finance_details, :has_pending_govpay_order) }

          before do
            transient_registration.finance_details = finance_details
            transient_registration.save
          end

          it "sends a pending online payment confirmation email with notify" do
            allow(Notify::RegistrationPendingOnlinePaymentEmailService)
              .to receive(:run)
              .and_call_original

            registration = described_class.run(transient_registration)

            expect(Notify::RegistrationPendingOnlinePaymentEmailService)
              .to have_received(:run)
              .with(registration: registration)
              .once
          end
        end

        context "when there is a pending balance" do
          let(:finance_details) { build(:finance_details, :has_required_data) }

          before do
            transient_registration.finance_details = finance_details
            transient_registration.save
          end

          it "sends a confirmation email with notify" do
            allow(Notify::RegistrationPendingPaymentEmailService)
              .to receive(:run)
              .and_call_original

            registration = described_class.run(transient_registration)

            expect(Notify::RegistrationPendingPaymentEmailService)
              .to have_received(:run)
              .with(registration: registration)
              .once
          end

          context "when the mailer fails" do
            before do
              the_error = StandardError.new("Oops!")

              allow(Notify::RegistrationPendingPaymentEmailService)
                .to receive(:run)
                .and_raise(the_error)

              allow(Airbrake)
                .to receive(:notify)
                .with(the_error, { registration_no: transient_registration.reg_identifier })
            end

            it "does not create an order item log" do
              expect { described_class.run(transient_registration) }.not_to change(OrderItemLog, :count).from(0)
            end

            it "notifies Airbrake" do
              described_class.run(transient_registration)

              expect(Airbrake).to have_received(:notify)
            end
          end
        end

        context "when there is a pending convictions check" do
          let(:transient_registration) do
            create(
              :new_registration,
              :has_required_data,
              :requires_conviction_check
            )
          end

          context "when the balance has been paid" do
            let(:finance_details) { build(:finance_details, :has_paid_order_and_payment) }

            before do
              transient_registration.finance_details = finance_details
              transient_registration.save
            end

            it "sends a confirmation email with notify" do
              allow(Notify::RegistrationPendingConvictionCheckEmailService)
                .to receive(:run)
                .and_call_original

              registration = described_class.run(transient_registration)

              expect(Notify::RegistrationPendingConvictionCheckEmailService)
                .to have_received(:run)
                .with(registration: registration)
                .once
            end

            context "when the notify service fails" do
              before do
                the_error = StandardError.new("Oops!")

                allow(Notify::RegistrationPendingConvictionCheckEmailService)
                  .to receive(:run)
                  .and_raise(the_error)

                allow(Airbrake)
                  .to receive(:notify)
                  .with(the_error, { registration_no: transient_registration.reg_identifier })
              end

              it "does not create an order item log" do
                expect { described_class.run(transient_registration) }.not_to change(OrderItemLog, :count).from(0)
              end

              it "notifies Airbrake" do
                described_class.run(transient_registration)

                expect(Airbrake).to have_received(:notify)
              end
            end
          end

          context "when there is an unpaid balance" do
            let(:finance_details) { build(:finance_details, :has_required_data) }

            before do
              allow(Notify::RegistrationPendingConvictionCheckEmailService).to receive(:run)

              transient_registration.finance_details = finance_details
              transient_registration.save
            end

            it "does not send the pending conviction check email" do
              described_class.run(transient_registration)

              expect(Notify::RegistrationPendingConvictionCheckEmailService).not_to have_received(:run)
            end

            it "does not create an order item log" do
              described_class.run(transient_registration)
              expect(OrderItemLog.count).to be_zero
            end
          end
        end
      end

      context "when the activation service raises an exception" do
        let(:transient_registration) { create(:new_registration, :has_required_data) }
        let(:registration_completion_service) { described_class.new }
        let(:activation_service_instance) { instance_double(RegistrationActivationService) }

        before do
          allow(described_class).to receive(:new).and_return(registration_completion_service)
          allow(registration_completion_service).to receive(:log_transient_registration_details)
          allow(RegistrationActivationService).to receive(:new).and_return(activation_service_instance)
          allow(activation_service_instance).to receive(:run).and_raise(StandardError)
        end

        it "logs the transient registration details" do
          complete_registration

          expect(registration_completion_service).to have_received(:log_transient_registration_details)
        end
      end

    end
  end
end
