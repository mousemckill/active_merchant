module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    class SberbankGateway < Gateway
      self.live_url = self.test_url = 'https://3dsec.sberbank.ru/payment/rest/'

      self.supported_countries = ['RU']
      self.default_currency = 810
      self.supported_cardtypes = [:visa, :master]

      self.homepage_url = 'http://www.sberbank.ru/'
      self.display_name = 'Sberbank'

      STANDARD_ERROR_CODE_MAPPING = {}

      def initialize(options={})
        requires!(options, :userName, :password)
        super
      end

      def purchase(money, options={})
        post = {
            :amount => money
        }

        add_order_number(post, options)
        add_order_return_url(post, options)

        commit('register.do', post)
      end

      private

      def add_order_return_url(post, options)
        post[:returnUrl] = options[:returnUrl] unless options[:returnUrl].blank?
      end

      def add_order_number(post, options)
        post[:orderNumber] = options[:orderNumber] unless options[:orderNumber].blank?
      end

      def parse(body)
        JSON.parse(body)
      end

      def commit(action, parameters)
        url = (test? ? test_url : live_url)

        parameters[:userName] = @options[:userName]
        parameters[:password] = @options[:password]

        response = parse(ssl_post(url + action, post_data(parameters)))

        Response.new(
          success_from(response),
          message_from(response),
          response,
          :test => test?,
          :error_code => error_code_from(response)
        )
      end

      def success_from(response)
        response["orderId"].present?
      end

      def message_from(response)
        response
      end

      def post_data(parameters = {})
        parameters.collect { |key, value| "#{key}=#{ CGI.escape(value.to_s)}" }.join("&")
      end

      def error_code_from(response)
        unless success_from(response)
          response["errorCode"]
        end
      end
    end
  end
end
