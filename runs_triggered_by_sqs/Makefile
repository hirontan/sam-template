QUEUENAME := test_queue
$(eval NAME := $(shell basename `pwd`))
STACKNAME := RunsTriggeredBySQS

start-platform:
	docker-compose up -d
	PATH=$(PATH) aws --endpoint-url=http://localhost:4576 sqs create-queue --queue-name '$(QUEUENAME)'

stop-platform:
	docker-compose down

network:
	$(eval NETWORK := $(shell docker network ls | grep $(NAME) | cut -f 1 -d ' '))

generate-env:
	$(eval LOCALSTACK_ID := $(shell docker ps | grep $(NAME)_localstack | cut -f 1 -d ' '))
	$(eval LOCALSTACK_IP := $(shell docker exec -it $(LOCALSTACK_ID) hostname -i))
	echo '{ "$(STACKNAME)Function": { "Env": "dev", "SQS_URL": "http://$(LOCALSTACK_IP):4576", "QueueName": "$(QUEUENAME)", "SQS_REGION": "us-east-1" } }' > ./env.json

install-pkgs:
	bundle install --gemfile $(NAME)/Gemfile --path build

invoke: network
	sam local invoke --parameter-overrides ParameterKey=Env,ParameterValue=dev -t template.yaml --env-vars env.json --docker-network $(NETWORK) --event event.json

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
