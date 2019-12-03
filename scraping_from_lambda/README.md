# scraping_from_lambda

特定URLをクローリングし、タイトルをスクレイピングする

## ローカル実行
```

$ make build-ruby-serverless-crawling-gems

$ make start-platform SCRAPING_URL=https://www.sora.flights
>> https://www.sora.flights は任意で変更してください。

$ make generate-env

$ make invoke
```

## 本番デプロイ
```
>> test-bucket は先に作っておいてください

$ make package

$ make deploy
```
