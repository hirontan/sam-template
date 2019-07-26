require 'bundler/setup'

require 'json'
require 'test/unit'
require 'mocha/test_unit'

require_relative '../../send_mail_from_lambda/app'

class SendMailFromLambdaTest < Test::Unit::TestCase
  # テストは後ほど書きます

  def expected_result
    { }
  end

  def test_lambda_handler
    assert_equal(lambda_handler(event: {}, context: ''), expected_result)
  end
end
