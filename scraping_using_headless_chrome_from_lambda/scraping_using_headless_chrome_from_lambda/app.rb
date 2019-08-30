require 'json'
# require 'webdrivers'
# require 'nokogiri'
# require 'childprocess'
require 'selenium-webdriver'

def lambda_handler(event:, context:)
  Selenium::WebDriver::Chrome::Service.driver_path = "/opt/bin/chromedriver"
  options = Selenium::WebDriver::Chrome::Options.new(
    binary: '/opt/bin/headless-chromium'
  )
  options.add_argument('--headless')
  options.add_argument('--disable-dev-shm-usage')
  options.add_argument('--single-process')
  options.add_argument('--no-sandbox')

  client = Selenium::WebDriver::Remote::Http::Default.new
  client.read_timeout = 120

  session = Selenium::WebDriver.for :chrome, http_client: client, options: options
  session.navigate.to "https://google.com/"
  title = session.title

  session.quit
  display_message(200, JSON.generate(title), "OK")

rescue => error
  display_message(400, error.message, error.backtrace)
end

def display_message(status_code, message, backtrace)
  {
    statusCode: status_code,
    body: {
      message: message,
      backtrace: backtrace
    }.to_json
  }
end
