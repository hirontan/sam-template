AWS サーバレスアプリケーションモデル テンプレート集
====

AWS サーバーレスアプリケーションモデル (AWS SAM) のよく使うテンプレートと、HelloWorldの実行環境を集約しています。

## Description
SAMでローカル開発をし、本番環境（AWS）にデプロイまでの流れを試行した結果を掲載していっているので、CloudFormationの書き方がわからない、SAMを初めて実行してみるなどの方を対象になると思います。

- [GitHub - awslabs/serverless-application-model: AWS Serverless Application Model (SAM) is an open-source framework for building serverless applications](https://github.com/awslabs/serverless-application-model)

## Usage
```
.
├── cloudformation_template：CloudFormationのテンプレートを保存してます。
│   ├── python37_template.yaml：Python3.7実行環境
│   ├── setting_cron_template.yaml：Cron（CloudWatch Events）をトリガーにする設定
│   └── sqs_template.yaml：SQSをトリガーにする設定
└── hello_world_lambda_for_ruby25：Ruby2.5でHelloWorld実行してます
└── hello_world_lambda_for_python37：Python3.7でHelloWorld実行してます
```

##### 実行コマンド
```
$ cd [利用するディレクトリ]

>> パッケージのインストール
$ make install-pkgs

>> 実行
$ make invoke

>> API起動
$ make start-api

>> テスト実行
$ make test

>> AWSにデプロイ
$ make package
$ make deploy
```

## Licence
MIT

## Author
[hirontan](https://github.com/hirontan)

