require 'test_helper'

class SberbankTest < Test::Unit::TestCase
  def setup
    @gateway = SberbankGateway.new(userName: 'login', password: 'password')
    @amount = 10000

    @options = {
      orderNumber: 1,
      returnUrl: 'http://ya.ru'
    }
  end

  def test_successful_purchase
    @gateway.expects(:ssl_post).returns(successful_purchase_response)

    response = @gateway.purchase(@amount, @options)
    assert response
    assert_instance_of Response, response
    assert_success response
    assert response.test?
  end

  def test_failed_purchase
    @gateway.expects(:ssl_post).returns(failed_purchase_response)

    response = @gateway.purchase(@amount, @options)
    assert_instance_of Response, response
    assert_failure response
  end

  private

  def successful_purchase_response
    <<-RESPONSE
{
  "orderId": "d4c097dc-855a-4991-b4e4-ac9c27780545",
  "formUrl": "https://3dsec.sberbank.ru/payment/merchants/ayvainform/payment_ru.html?mdOrder=d4c097dc-855a-4991-b4e4-ac9c27780545"
}
    RESPONSE
  end

  def failed_purchase_response
    <<-RESPONSE
{
  "errorCode": "4",
  "errorMessage": "Номер заказа не может быть пуст"
}
    RESPONSE
  end
end
