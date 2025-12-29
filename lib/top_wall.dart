import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:greendayo/domain/model/user.dart';
import 'package:greendayo/l10n/app_localizations.dart';
import 'package:greendayo/ui/pages/top/top_page.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class TopWall extends HookConsumerWidget {
  const TopWall({super.key, required Widget this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);
    return userAsync.when(data: (user) {
      if (user == null) {
        return _topApp(context, ref);
      }
      FlutterNativeSplash.remove();
      return child;
    }, error: (error, stack) {
      return Container();
    }, loading: () {
      return Container();
    });
  }

  Widget _topApp(context, ref) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: const [Locale('ja')],
      title: 'すしぺろ',
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.blueGrey,
        useMaterial3: true,
        textTheme: const TextTheme(
          titleSmall: TextStyle(fontWeight: FontWeight.w700),
          titleMedium: TextStyle(fontWeight: FontWeight.w700),
          headlineSmall: TextStyle(fontWeight: FontWeight.w700),
          headlineMedium: TextStyle(fontWeight: FontWeight.w700),
          labelSmall: TextStyle(fontWeight: FontWeight.w700),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      onGenerateRoute: (route) {
        return MaterialPageRoute(
          builder: (context) => TopPage(),
        );
      },
      onGenerateInitialRoutes: (initialRoute) {
        final pattern = RegExp(
          r"/profile(?:/(?=\w+))?(\w+)?$",
        );
        final matches = pattern.allMatches(initialRoute);
        if (matches.isNotEmpty) {
          final userId = matches.first.group(1);
          return [
            MaterialPageRoute(
              builder: (context) => TopPage(userId: userId),
            ),
          ];
        }
        return [
          MaterialPageRoute(
            builder: (context) => TopPage(),
          ),
        ];
      },
    );
  }
}
