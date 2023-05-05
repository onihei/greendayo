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
