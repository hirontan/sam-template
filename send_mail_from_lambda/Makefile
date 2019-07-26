S3BUCKET := test_bucket
$(eval NAME := $(shell basename `pwd`))
STACKNAME := SendMailFromLambda
EMAIL := test@example.com

start-platform:
	docker-compose up -d
	PATH=$(PATH) aws --endpoint-url=http://localhost:4579 ses verify-email-identity --email-address $(EMAIL)

stop-platform:
	docker-compose down

network:
	$(eval NETWORK := $(shell docker network ls | grep $(NAME) | cut -f 1 -d ' '))

generate-env:
	$(eval LOCALSTACK_ID := $(shell docker ps | grep $(NAME)_localstack | cut -f 1 -d ' '))
	$(eval LOCALSTACK_IP := $(shell docker exec -it $(LOCALSTACK_ID) hostname -i))
	echo '{ "$(STACKNAME)Function": { "SES_URL": "http://$(LOCALSTACK_IP):4579", "TO_ADDRESSES": "test@ecample.com", "FROM_ADDRESS": "$(EMAIL)" } }' > ./env.json

install-pkgs:
	bundle install --gemfile $(NAME)/Gemfile --path build

invoke: network
	echo {} | sam local invoke -t template.yaml --env-vars env.json --docker-network $(NETWORK) 

init: start-platform generate-env install-pkgs invoke

start-api: network
	sam local start-api -t template.yaml --env-vars env.json --docker-network $(NETWORK)

test:
	bundle install --path tests/unit/build/
	ruby tests/unit/test_handler.rb

package:
	aws cloudformation package --template-file template.yaml --output-template-file packaged-template.yaml --s3-bucket $(S3BUCKET) --s3-prefix $(NAME)

deploy:
	aws cloudformation deploy --template-file packaged-template.yaml --stack-name $(STACKNAME) --capabilities CAPABILITY_IAM
