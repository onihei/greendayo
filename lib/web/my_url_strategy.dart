export 'my_url_strategy_stub.dart'
    if (dart.library.html) 'my_url_strategy_web.dart';

///
/// Flutter Web で作成した画面にブラウザでアクセスするとURLが /#/ となります。(https://susipero.com/#/)
/// これを防ぐため UrlStrategy に PathUrlStrategy を設定します。
/// この設定は Webビルドだけで行うため、条件付きの exportをしています。
///
/// また、nginxに以下の設定も必要です。これらがないと次のようなパスへのアクセスが404になります。
/// https://susipero.com/profile/xxxxxx
/// ```
/// location / {
///    try_files $uri $uri/ /index.html;
/// }
/// ```
