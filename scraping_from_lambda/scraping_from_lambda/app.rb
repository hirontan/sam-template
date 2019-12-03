require 'bundler/setup'

require 'aws-sdk-s3'
require 'open-uri'
require 'nokogiri'
require 'robotex'
require 'json'

def lambda_handler(event:, context:)
  bucket_name = ENV['BucketName']
  event['Records'].each do |record|
    raise "using bucket different." if record['s3']['bucket']['name'] != bucket_name

    content = get_content(record['s3']['object']['key'], bucket_name)
    charset = 'utf-8'
    body = JSON.parse(content.body.read)
    html = crawl_html(body['url'], charset)
    scraping_title_tag(html, charset)
  end

  display_message(200, "OK")
rescue => error
  display_message(400, error.message)
end

def check_crawler_availability(url)
  robotex = Robotex.new
  robotex.allowed?(url)
  robotex.delay!(url)
end

def crawl_html(url, charset)
  check_crawler_availability(url)

  html = open(url){|f| f.read }

  bucket = ENV['BucketName']
  put_content(bucket, url, html)

  html
end

def scraping_title_tag(html, charset)
  doc = Nokogiri::HTML.parse(html, nil, charset)
  puts doc.title
end

def put_content(bucket, filename, body)
  client = construct_s3_client
  client.put_object(bucket: bucket, key: "#{require_path}/#{filename}", body: body)
end

def require_path()
  'scraping_from_lambda'
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
      endpoint: ENV['S3_URL'],
      force_path_style: true
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
