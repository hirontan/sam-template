require 'bundler/setup'

require 'aws-sdk-s3'
require 'json'

def lambda_handler(event:, context:)
  bucket = 'test_bucket'
  filename = 's3test.json'

  put_content(filename, bucket)
  content = get_content(filename, bucket)

  puts content.body.read

  display_message(200, "OK")
rescue => error
  display_message(400, error.message)
end

def put_content(filename, bucket)
  client = construct_s3_client
  client.put_object(bucket: bucket, key: "#{require_path}/#{filename}", body: create_body)
end

def get_content(filename, bucket)
  client = construct_s3_client
  client.get_object(bucket: bucket, key: "#{require_path}/#{filename}")
end

def construct_s3_client()
  Aws::S3::Client.new(set_config)
end

def set_config()
  if ENV['S3_URL'] == 'None'
    {
      region: ENV['AWS_REGION'],
      access_key_id: ENV['AWS_ACCESS_KEY_ID'],
      secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
    }
  else
    {
      endpoint: ENV['S3_URL']
    }
  end
end

def require_path()
  'save_file_from_lambda_to_s3'
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
