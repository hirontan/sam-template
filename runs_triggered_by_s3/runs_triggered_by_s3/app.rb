require 'bundler/setup'

require 'aws-sdk-s3'
require 'json'

def lambda_handler(event:, context:)
  bucket_name = ENV['BucketName']
  event['Records'].each do |record|
    raise "using bucket different." if record['s3']['bucket']['name'] != bucket_name
    puts record['s3']['object']['key']
    
    content = get_content(record['s3']['object']['key'], bucket_name)
  end

  display_message(200, "OK")
rescue => error
  display_message(400, error.message)
end

def get_content(key, bucket)
  client = construct_s3_client
  client.get_object(bucket: bucket, key: key)
end

def construct_s3_client()
  Aws::S3::Client.new(set_config)
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
      endpoint: ENV['S3_URL']
    }
  end
end

def display_message(status_code, message)
  {
    statusCode: status_code,
    body: {
      message: message
    }.to_json
  }
end
