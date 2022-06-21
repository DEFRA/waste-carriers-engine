# frozen_string_literal: true

require "rails_helper"
require "faker"

module WasteCarriersEngine
  RSpec.describe RegistrationCompletionService do
    describe ".run" do
      let(:transient_registration) do
        create(
          :new_registration,
          :has_required_data
        )
      end

      it "generates a new registration and copy data to it" do
        registration_scope = WasteCarriersEngine::Registration.where(reg_identifier: transient_registration.reg_identifier)

        expect(registration_scope.any?).to be_falsey

        registration = described_class.run(transient_registration)

        expect(registration.reg_identifier).to be_present
        expect(registration.contact_address).to be_present
        expect(registration.company_address).to be_present
        expect(registration.expires_on).to be_present
        expect(registration.metaData.route).to be_present
        expect(registration.metaData.date_registered).to be_present
        expect(registration).to be_pending
      end

      it "deletes the transient registration" do
        token = transient_registration.token

        described_class.run(transient_registration)

        new_registration_scope = WasteCarriersEngine::NewRegistration.where(token: token)

        expect(new_registration_scope.any?).to be_falsey
      end

      context "when the registration is a lower tier registration" do
        let(:transient_registration) do
          create(
            :new_registration,
            :has_required_lower_tier_data
          )
        end

        it "activates the registration, set up finance details and does not set an expire date" do
          registration = described_class.run(transient_registration)

          expect(registration.expires_on).to be_nil
          expect(registration).to be_active
          expect(registration.finance_details).to be_present
          expect(registration.finance_details.orders.count).to eq(1)
          expect(registration.finance_details.balance).to eq(0)
        end
      end

      context "when the balance has been cleared and there are no pending convictions checks" do
        let(:finance_details) { build(:finance_details, :has_paid_order_and_payment) }
        let(:registration) { described_class.run(transient_registration) }

        before do
          transient_registration.finance_details = finance_details
          transient_registration.save
        end

        it "activates the registration" do
          expect(registration).to be_active
        end

        it "creates the correct number of order item logs" do
          expect { registration }.to change { OrderItemLog.count }
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
            expect { registration }.to change { OrderItemLog.count }
              .from(0)
              .to(transient_registration.finance_details.orders.sum { |o| o.order_items.length })
          end

          it "captures the order item types correctly" do
            order_items_by_type = {}
            registration.finance_details.orders.map do |o|
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
            expect(OrderItemLog.where(activated_at: registration.metaData.dateActivated).count).to eq OrderItemLog.count
          end
        end
      end

      context "when there is a pending worldpay balance" do
        let(:finance_details) { build(:finance_details, :has_pending_worldpay_order) }

        before do
          transient_registration.finance_details = finance_details
          transient_registration.save
        end

        it "sends a pending worldpay confirmation email with notify" do
          allow(Notify::RegistrationPendingWorldpayPaymentEmailService)
            .to receive(:run)
            .and_call_original

          registration = described_class.run(transient_registration)

          expect(Notify::RegistrationPendingWorldpayPaymentEmailService)
            .to have_received(:run)
            .with(registration: registration)
            .once
        end

        context "when the mailer fails" do
          before do
            the_error = StandardError.new("Oops!")

            allow(Notify::RegistrationPendingWorldpayPaymentEmailService)
              .to receive(:run)
              .and_raise(the_error)

            expect(Airbrake)
              .to receive(:notify)
              .with(the_error, { registration_no: transient_registration.reg_identifier })
          end

          it "does not create an order item log" do
            expect { described_class.run(transient_registration) }.not_to change { OrderItemLog.count }.from(0)
          end

          it "notifies Airbrake" do
            described_class.run(transient_registration)
          end
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

            expect(Airbrake)
              .to receive(:notify)
              .with(the_error, { registration_no: transient_registration.reg_identifier })
          end

          it "does not create an order item log" do
            expect { described_class.run(transient_registration) }.not_to change { OrderItemLog.count }.from(0)
          end

          it "notifies Airbrake" do
            described_class.run(transient_registration)
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

              expect(Airbrake)
                .to receive(:notify)
                .with(the_error, { registration_no: transient_registration.reg_identifier })
            end

            it "does not create an order item log" do
              expect { described_class.run(transient_registration) }.not_to change { OrderItemLog.count }.from(0)
            end

            it "notifies Airbrake" do
              described_class.run(transient_registration)
            end
          end
        end

        context "when there is an unpaid balance" do
          let(:finance_details) { build(:finance_details, :has_required_data) }

          before do
            transient_registration.finance_details = finance_details
            transient_registration.save
          end

          it "does not send the pending conviction check email" do
            expect(Notify::RegistrationPendingConvictionCheckEmailService).to_not receive(:run)

            described_class.run(transient_registration)
          end

          it "does not create an order item log" do
            described_class.run(transient_registration)
            expect(OrderItemLog.count).to be_zero
          end
        end
      end
    end
  end
end
