BUCKETNAME := test_bucket
$(eval NAME := $(shell basename `pwd`))
STACKNAME := ScrapingUsingHeadlessChromeFromLambda

# 実行時は、`make start-platform SCRAPING_URL=xxxxxxxxxxx`
start-platform: create-event
	docker-compose up -d
	PATH=$(PATH) aws --endpoint-url=http://localhost:4572 s3api create-bucket --bucket $(BUCKETNAME)
	PATH=$(PATH) aws --endpoint-url=http://localhost:4572 s3 cp test.json s3://$(BUCKETNAME)/$(NAME)/

stop-platform:
	docker-compose down

network:
	$(eval NETWORK := $(shell docker network ls | grep $(NAME) | cut -f 1 -d ' '))

generate-env:
	$(eval LOCALSTACK_ID := $(shell docker ps | grep $(NAME)_localstack | cut -f 1 -d ' '))
	$(eval LOCALSTACK_IP := $(shell docker exec -it $(LOCALSTACK_ID) hostname -i))
	echo '{ "$(STACKNAME)Function": { "Env": "dev", "S3_URL": "http://$(LOCALSTACK_IP):4572", "BucketName": "$(BUCKETNAME)", "S3_REGION": "us-east-1" } }' > ./env.json

# 実行時は、`make create-event SCRAPING_URL=xxxxxxxx`
# create-event:
#	echo '{ "id": "1", "url": "$(SCRAPING_URL)" }' > ./test.json

install-pkgs:
	bundle install --gemfile $(NAME)/Gemfile --path build

# build: network
# 	sam build --use-container --parameter-overrides ParameterKey=Env,ParameterValue=dev -t template.yaml --docker-network $(NETWORK)

invoke: # network
	# sam local invoke $(STACKNAME)Function --parameter-overrides ParameterKey=Env,ParameterValue=dev --env-vars env.json --docker-network $(NETWORK) --event event.json
	sam local invoke -t template.yaml --parameter-overrides ParameterKey=Env,ParameterValue=dev --env-vars env.json --event event.json

init: start-platform generate-env install-pkgs invoke

start-api: network
	sam local start-api -t template.yaml --env-vars env.json --docker-network $(NETWORK)

test:
	bundle install --path tests/unit/build/
	ruby tests/unit/test_handler.rb

package:
	aws cloudformation package --template-file template.yaml --output-template-file packaged-template.yaml --parameter-overrides Env=prod --s3-bucket $(S3BUCKET) --s3-prefix $(NAME)

deploy:
	aws cloudformation deploy --template-file packaged-template.yaml --stack-name $(STACKNAME) --capabilities CAPABILITY_IAM --parameter-overrides Env=prod

install-layer-pkgs:
	bundle install --gemfile Gemfile --path build --without test

make-gems-zipfile:
	mkdir -p ruby-serverless-chrome-gems/ruby/gems/2.5.0/
	cp -r build/ruby/2.5.0/* ruby-serverless-chrome-gems/ruby/gems/2.5.0/
	zip -r zip/ruby-serverless-chrome-gems.zip ./ruby-serverless-chrome-gems/ruby

upload-gems-layer:
	PATH=$(PATH) aws lambda publish-layer-version --layer-name ruby-serverless-chrome-gems --zip-file fileb://zip/ruby-serverless-chrome-gems.zip --compatible-runtimes ruby2.5

make-bin-zipfile:
	mkdir -p layer/bin
	wget https://github.com/adieuadieu/serverless-chrome/releases/download/v1.0.0-55/stable-headless-chromium-amazonlinux-2017-03.zip
	unzip stable-headless-chromium-amazonlinux-2017-03.zip -d ruby-serverless-chrome-bin/bin/
	rm stable-headless-chromium-amazonlinux-2017-03.zip
	curl -SL https://chromedriver.storage.googleapis.com/2.43/chromedriver_linux64.zip > chromedriver.zip
	unzip chromedriver.zip -d ruby-serverless-chrome-bin/bin/
	rm chromedriver.zip
	mkdir zip
	zip -r zip/ruby-serverless-chrome-bin.zip ./layer/bin

upload-bin-layer:
	PATH=$(PATH) aws lambda publish-layer-version --layer-name ruby-serverless-chrome-bin --zip-file fileb://zip/ruby-serverless-chrome-bin.zip --compatible-runtimes ruby2.5
