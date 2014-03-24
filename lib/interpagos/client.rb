module Interpagos
  class Client
    attr_accessor :client_id, :client_pin

    def initialize(options = {})
      self.client_id    = options[:client_id]
      self.client_pin   = options[:client_pin]
      self.test         = !!options[:test]
    end

    def payment(options)
      Interpagos::Payment.new(options).tap do |payment|
        payment.client = self
      end
    end

    def response(options)
      Interpagos::Response.new(options).tap do |response|
        response.client = self
      end
    end

    def test?
      @test
    end

    def test=(test)
      @test = test
    end
  end
end
