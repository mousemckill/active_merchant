require 'test_helper'

class RemoteSberbankTest < Test::Unit::TestCase
  def setup
    @gateway = SberbankGateway.new(fixtures(:sberbank))
    @amount = 10000

    @options = {
        orderNumber: Random.rand(10**10),
        returnUrl: 'http://ya.ru'
    }
  end

  def test_successful_purchase
    assert response = @gateway.purchase(@amount, @options)
    assert_success response
    assert_instance_of Response, response
    assert_success response
  end

  def test_failed_purchase
    options = {
        returnUrl: @options[:returnUrl]
    }

    response = @gateway.purchase(@amount, options)
    assert_failure response
    assert_equal JSON.parse('{"errorCode":"4","errorMessage":"Номер заказа не может быть пуст"}'), response.message
  end

  def test_bad_login
    @gateway.options[:userName] = 'X'
    assert response = @gateway.purchase(@amount, @options)

    assert_equal Response, response.class
    assert_failure response
  end

end
