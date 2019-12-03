#!/bin/bash -x

set -e

bundle install --gemfile=layers/gemfiles/Gemfile_ruby-serverless-crawling-gems --path=../../ruby-serverless-crawling-gems

rm -rf ruby-serverless-crawling-gems && mkdir -p ruby-serverless-crawling-gems/ruby/gems

docker build -t ruby25-builder -f layers/docker/Dockerfile_ruby-serverless-crawling-gems .

CONTAINER=$(docker run -d ruby25-builder false)

docker cp \
    $CONTAINER:/var/task/vendor/bundle/ruby/2.5.0 \
    ruby-serverless-crawling-gems/ruby/gems/2.5.0

docker rm $CONTAINER
