require 'bundler/setup'

require 'aws-sdk-ses'
require 'json'

def lambda_handler(event:, context:)
  client = construct_ses_client
  resp = client.send_email(set_format)
  display_message(200, "OK")
rescue => error
  display_message(400, error.message)
end

def construct_ses_client()
  Aws::SES::Client.new(set_config)
end

def set_config()
  if ENV['Env'] == 'prod'
    {
      region: ENV['AWS_REGION'],
      access_key_id: ENV['AWS_ACCESS_KEY_ID'],
      secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
    }
  else
    {
      endpoint: ENV['SES_URL']
    }
  end
end

def set_source()
  if ENV['FROM_ADDRESS'] == 'None'
    'test@example.com'
  else
    ENV['FROM_ADDRESS']
  end
end

def set_destination()
  if ENV['TO_ADDRESSES'] == 'None'
    ['test@example.com']
  else
    ENV['TO_ADDRESSES'].split(',')
  end
end

def set_format()
  {
    destination: {
      bcc_addresses: [ ], 
      cc_addresses: [ ], 
      to_addresses: set_destination, 
    }, 
    message: {
      body: {
        html: {
          charset: "UTF-8", 
          data: "This message body contains HTML formatting. It can, for example, contain links like this one: <a class=\"ulink\" href=\"http://docs.aws.amazon.com/ses/latest/DeveloperGuide\" target=\"_blank\">Amazon SES Developer Guide</a>.", 
        }, 
        text: {
          charset: "UTF-8", 
          data: "This is the message body in text format.", 
        }, 
      }, 
      subject: {
        charset: "UTF-8", 
        data: "Test email", 
      }, 
    }, 
    reply_to_addresses: [ ], 
    return_path: "", 
    return_path_arn: "", 
    source: set_source, 
    source_arn: "", 
  }
end

def display_message(status_code, message)
  {
    statusCode: status_code,
    body: {
      message: message
    }.to_json
  }
end
