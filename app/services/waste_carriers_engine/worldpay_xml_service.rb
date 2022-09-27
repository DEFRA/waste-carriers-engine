# frozen_string_literal: true

require "countries"

module WasteCarriersEngine
  class WorldpayXmlService
    include CanBuildWorldpayXml

    def initialize(transient_registration, order)
      @transient_registration = transient_registration
      @order = order
    end

    def build_xml
      builder = Nokogiri::XML::Builder.new do |xml|
        build_doctype(xml)

        xml.paymentService(version: "1.4", merchantCode: merchant_code) do
          xml.submit do
            build_order(xml)
          end
        end
      end

      builder.to_xml
    end

    private

    def build_order(xml)
      order_code = @order.order_code
      reg_identifier = @transient_registration.reg_identifier
      company_name = @transient_registration.company_name
      value = @order.total_amount

      xml.order(orderCode: order_code) do
        xml.description "Your Waste Carrier Registration #{reg_identifier}"

        xml.amount(currencyCode: "GBP", value: value, exponent: "2")

        case @transient_registration
        when WasteCarriersEngine::RenewingRegistration
          xml.orderContent "Waste Carrier Registration renewal: #{reg_identifier} for #{company_name}"
        when WasteCarriersEngine::EditRegistration
          xml.orderContent "Waste Carrier Registration edit: #{reg_identifier} for #{company_name}"
        else
          xml.orderContent "Waste Carrier Registration: #{reg_identifier} for #{company_name}"
        end

        build_payment_methods(xml)
        build_shopper(xml)
        build_address(xml)
      end
    end

    def build_payment_methods(xml)
      xml.paymentMethodMask do
        xml.include(code: "VISA-SSL")
        xml.include(code: "MAESTRO-SSL")
        xml.include(code: "ECMC-SSL")
      end
    end

    def build_shopper(xml)
      email = @transient_registration.email_to_send_receipt

      xml.shopper do
        xml.shopperEmailAddress email
      end
    end

    def build_address(xml)
      first_name = @transient_registration.first_name
      last_name = @transient_registration.last_name

      address = @transient_registration.registered_address

      address1 = [address.house_number, address.address_line1].join(" ")
      address2 = address.address_line2
      postcode = address.postcode.presence || "UNKNOWN"
      city = address.town_city
      country_code = look_up_country_code(address.country)

      xml.billingAddress do
        xml.address do
          xml.firstName first_name
          xml.lastName last_name
          xml.address1 address1
          xml.address2 address2
          xml.postalCode postcode
          xml.city city
          xml.countryCode country_code
        end
      end
    end

    def look_up_country_code(country_name)
      country = ISO3166::Country.find_country_by_iso_short_name(country_name)
      # If we didn't provide a country or no match was found, use GB as default
      return "GB" if country.nil?

      country.alpha2
    end
  end
end
