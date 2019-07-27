require 'bundler/setup'

require 'aws-sdk-sqs'
require 'json'

def lambda_handler(event:, context:)
  queue_name = ENV['QueueName']
  event['Records'].each do |record|
    body = JSON.parse(record['body'])
    number_en = body['number']
    send_message_to_sqs(queue_name, number_en)
  end

  display_message(200, "OK")
rescue => error
  display_message(400, error.message)
end

def send_message_to_sqs(queue_name, message_body)
  client = construct_sqs_client
  queue_url = set_queue_url(client, queue_name)
  client.send_message(queue_url: queue_url, message_body: message_body)
end

def construct_sqs_client()
  Aws::SQS::Client.new(set_config)
end

def set_queue_url(client, queue_name)
  if ENV['Env'] == 'prod'
    client.get_queue_url(queue_name: queue_name).queue_url
  else
    "#{ENV['SQS_URL']}/queue/#{queue_name}"
  end
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
      region: ENV['SQS_REGION'],
      endpoint: ENV['SQS_URL']
    }
  end
end

def create_body()
  '{ "text": "Hello World" }'
end

def display_message(status_code, message)
  {
    statusCode: status_code,
    body: {
      message: message
    }.to_json
  }
end
