import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/design_tokens.dart';
import 'config/router.dart';
import 'l10n/app_localizations.dart';
import 'providers/account_language_provider.dart';
import 'providers/locale_provider.dart';
import 'services/firebase_setup.dart';
import 'services/push_router.dart';
import 'services/push_service.dart';
import 'services/session_telemetry.dart';
import 'services/share_intent.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final ready = await initFirebase();
  runApp(
    ProviderScope(
      overrides: [firebaseReadyProvider.overrideWithValue(ready)],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeProvider);
    ref.watch(sessionTelemetryProvider);
    ref.watch(pushRegistrationProvider);
    ref.watch(accountLanguageSyncProvider);
    ref.watch(pushNotificationsProvider);
    ref.watch(shareIntentProvider);

    return MaterialApp.router(
      title: 'Andoza AI Mobile',
      theme: AndozaTheme.lightTheme(),
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
      // A tap on empty space closes the keyboard. iOS number and phone pads
      // have no return key, so without this a phone or ceiling field could
      // not be dismissed and kept the buttons under it hidden. Taps on
      // controls still go to the controls: they win the gesture arena.
      builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
        // The app is light: dark status-bar icons by default. A dark screen
        // (the 360° scan) declares light icons over this; without a default
        // here its light icons stuck after leaving it, white on white.
        value: SystemUiOverlayStyle.dark,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: child,
        ),
      ),
    );
  }
}
