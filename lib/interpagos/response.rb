module Interpagos
  class Response
    SIGNATURE_JOIN = "-"

    attr_accessor :client
    attr_accessor :params

    def initialize(params)
      self.params = params
    end

    def test?
      params["Test"] == "1"
    end

    def currency
      params["Currency"]
    end

    def signature
      params["TokenTransactionCode"]
    end

    def state
      case transaction_code
      when "00" then :approved
      when "01" then :expired
      when "02" then :approved
      when "03" then :declined
      when "04" then :declined
      when "05" then :declined
      when "06" then :declined
      when "07" then :declined
      when "08" then :declined
      when "09" then :declined
      when "10" then :pending
      when "11" then :pending
      when "15" then :pending
      when "16" then :cash # No idea if this mean approved or pending (Official manual page 18)
      else
        :unknown
      end
    end

    def success?
      self.state == :approved
    end

    def failure?
      [:error, :expired, :declined].include? self.state
    end

    def total_amount
      Float(self.params["TotalAmount"])
    end

    def tax_amount
      Float(self.params["TaxAmount"])
    end

    def base_amount
      Float(self.params["BaseAmount"])
    end

    def reference
      self.params["IdReference"]
    end

    def transaccion_id
      self.params["TransactionId"]
    end

    def transaction_message
      self.params["TransactionMessage"]
    end

    def transaction_code
      self.params["TransactionCode"]
    end

    def valid?
      self.signature == Digest::SHA1.hexdigest([
        self.client.client_id,
        self.client.client_pin,
        self.reference,
        ("%.2f" % self.total_amount),
        self.transaction_code
      ].join(SIGNATURE_JOIN))
    end
  end
end
