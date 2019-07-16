S3BUCKET := test_bucket
$(eval NAME := $(shell basename `pwd`))

install-pkgs:
	pip install -r src/requirements.txt -t src/build/

invoke:
	echo {} | sam local invoke -t template.yaml

package:
	aws cloudformation package --template-file template.yaml --output-template-file packaged-template.yaml --s3-bucket $(S3BUCKET) --s3-prefix $(NAME)

deploy:
	aws cloudformation deploy --template-file packaged-template.yaml --stack-name $(NAME) --capabilities CAPABILITY_IAM
