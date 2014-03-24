module Interpagos
  class Payment < Hashie::Dash
    GATEWAY = "https://secure.interpagos.net/gateway/"
    TEST_GATEWAY= ""
    SIGNATURE_JOIN = "-"

    attr_accessor :client

    # Configurables
    property :reference, :required => true
    property :description, :required => true
    property :base_amount, :required => true
    property :tax_amount, :required => true
    property :total_amount, :required => true
    property :currency, :required => true, :default => "COP"
    property :language, :required => true, :default => "SP"

    property :response_url, :required => true
    property :confirmation_url, :required => true
    property :extra
    property :buyer_name
    property :buyer_email

    def signature
      Digest::SHA1.hexdigest([
        self.client.client_id,
        self.client.client_pin,
        self.reference,
        ("%.2f" % self.amount)
      ].join(SIGNATURE_JOIN))
    end

    def form(options = {})
      id = params[:id] || "interpagos"

      form = <<-EOF
        <form
          action="#{self.gateway_url}"
          method="POST"
          id="#{id}"
          class="#{params[:class]}">
      EOF

      self.params.each do |key, value|
        form << "<input type=\"hidden\" name=\"#{key}\" value=\"#{value}\" />" if value
      end

      form << yield if block_given?

      form << "</form>"

      form
    end

    protected
      def gateway_url
        self.client.test? ? TEST_GATEWAY : GATEWAY
      end

      def params
        params = {
          "IdClient"            => self.client.client_id,
          "Token"               => self.signature,
          "IdReference"         => self.reference,
          "Reference"           => self.description,
          "Currency"            => self.currency,
          "BaseAmount"          => ("%.2f" % self.base_amount),
          "TaxAmount"           => ("%.2f" % self.tax_amount),
          "TotalAmount"         => ("%.2f" % self.total_amount),
          "ShopperName"         => self.buyer_name,
          "ShopperEmail"        => self.buyer_email,
          "LenguajeInterface"   => self.language,
          "PayMethod"           => 1,
          "RecurringBill"       => 0,
          "RecurringBillTimes"  => 0,
          "PageAnswer"          => self.response_url,
          "PageConfirm"         => self.confirmation_url,
          "Test"                => (self.client.test? ? 1 : 0)
        }

        if self.extra
          params["ExtraData1"] = self.extra[0,249]
          params["ExtraData2"] = self.extra[250,499]
          params["ExtraData3"] = self.extra[500,749]
        end

        params
      end

  end
end
