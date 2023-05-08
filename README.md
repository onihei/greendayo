# greendayo

https://susipero.com のWebアプリケーションの実装です。
基本的には webビルドだけです。
しかしできるだけNativeビルドと動作ができるように目指します。
パフォーマンスやメモリリークの調査にはnativeで動作させてFlutter Dev Toolsが必要だからです。

## Getting Started

スプラッシュ画面の作成
```shell
flutter pub run flutter_native_splash:create
```

ビルド
```shell
flutter build web
```

他のデバイスからアクセスさせる
http://192.168.10.201:10010
```shell
flutter run -d web-server --web-hostname=0.0.0.0 --web-port=10010
```
ß