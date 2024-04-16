# greendayo

https://susipero.com のWebアプリケーションの実装です。
基本的には webビルドだけです。
しかしできるだけNativeビルドと動作ができるように目指します。
パフォーマンスやメモリリークの調査にはnativeで動作させてFlutter Dev Toolsが必要だからです。

## Getting Started

スプラッシュ画面の作成
```shell
dart pub run flutter_native_splash:create
```

### freezedによるコード生成 とフォーマット
```shell
dart run build_runner build --delete-conflicting-outputs

dart format $(find lib -name "*.dart" -not \( -name "*.*freezed.dart" -o -name "*.pb*.dart" -o -name "*.*g.dart" \) )
dart fix --apply --code=unused_import
```

### 依存パッケージを自動的に最新版にアップグレードする
```shell
flutter pub upgrade --major-versions
```

### パッケージネームを変える
```shell
flutter pub run change_app_package_name:main com.susipero.greendayo
```

### アイコンファイルを生成する
```shell
flutter pub run flutter_launcher_icons:main
```

ビルド
```shell
dart build web
```

他のデバイスからアクセスさせる
http://192.168.10.201:10010
```shell
dart run -d web-server --web-hostname=0.0.0.0 --web-port=10010
```
