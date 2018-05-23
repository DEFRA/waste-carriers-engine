require "nokogiri"

class WorldpayService
  def initialize(transient_registration)
    @transient_registration = transient_registration
    @xml = build_xml
  end

  private

  def build_xml
    builder = Nokogiri::XML::Builder.new do |xml|

      xml.doc.create_internal_subset(
        "paymentService",
        "-//WorldPay/DTD WorldPay PaymentService v1/EN",
        "http://dtd.worldpay.com/paymentService_v1.dtd"
      )

      xml.paymentService(version: "1.4", merchantCode: "[tbd]") do
        xml.submit do
          xml.order(orderCode: "[tbd]") do
            xml.description "Your Waste Carrier Registration [reg_identifier]"

            xml.amount(currencyCode: "GBP", value: "[total_cost]", exponent: "2")

            xml.orderContent "New Waste Carrier Registration: [reg_identifier] for [company_name]"

            xml.paymentMethodMask do
              xml.include(code: "VISA-SSL")
              xml.include(code: "MAESTRO-SSL")
              xml.include(code: "ECMC-SSL")
            end

            xml.shopper do
              # Account email
              xml.shopperEmailAddress "[email]"
            end

            xml.billingAddress do
              # Registered address - this prefills form, but user can change it
              xml.address do
                xml.firstName "[first_name]"
                xml.lastName "[last_name]"
                xml.address1 "[address_line_1]"
                xml.address2 "[address_line_2]"
                xml.postalCode "[postcode]"
                xml.city "[city]"
                xml.countryCode "[countrycode]" # eg GB
              end
            end
          end
        end
      end
    end

    builder.to_xml
  end
end
