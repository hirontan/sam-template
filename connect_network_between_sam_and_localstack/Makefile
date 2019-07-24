S3BUCKET := test_bucket
$(eval NAME := $(shell basename `pwd`))
STACKNAME := ConnectNetworkBetweenSAMAndLocalStack

start-platform:
	docker-compose up -d

stop-platform:
	docker-compose down

network:
	$(eval NETWORK := $(shell docker network ls | grep $(NAME) | cut -f 1 -d ' '))

install-pkgs:
	bundle install --gemfile hello_world/Gemfile --path build

invoke: network
	sam local invoke -t template.yaml --docker-network $(NETWORK) -e event.json

start-api: network
	sam local start-api -t template.yaml --docker-network $(NETWORK)

test:
	bundle install --path tests/unit/build/
	ruby tests/unit/test_handler.rb

package:
	aws cloudformation package --template-file template.yaml --output-template-file packaged-template.yaml --s3-bucket $(S3BUCKET) --s3-prefix $(NAME)

deploy:
	aws cloudformation deploy --template-file packaged-template.yaml --stack-name $(STACKNAME) --capabilities CAPABILITY_IAM
