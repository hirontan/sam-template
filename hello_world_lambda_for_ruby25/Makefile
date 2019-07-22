S3BUCKET := test_bucket
$(eval NAME := $(shell basename `pwd`))

install-pkgs:
	bundle install --gemfile hello_world/Gemfile --path build

invoke:
	sam local invoke -t template.yaml --event event.json

start-api:
	sam local start-api

test:
	bundle install --path tests/unit/build/
	ruby tests/unit/test_handler.rb

package:
	aws cloudformation package --template-file template.yaml --output-template-file packaged-template.yaml --s3-bucket $(S3BUCKET) --s3-prefix $(NAME)

deploy:
	aws cloudformation deploy --template-file packaged-template.yaml --stack-name $(NAME) --capabilities CAPABILITY_IAM
