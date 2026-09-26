import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/app_router.dart';
import 'core/app_theme.dart';
import 'core/locale_controller.dart';
import 'l10n/app_localizations.dart';

void main() {
  runApp(const KrishiSenseApp());
}

class KrishiSenseApp extends StatelessWidget {
  const KrishiSenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: localeController,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'KrishiSense',
          debugShowCheckedModeBanner: false,

          // Theme
          theme: AppTheme.lightTheme,

          // Localization
          locale: localeController.locale,

          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          supportedLocales: AppLocalizations.supportedLocales,

          // Router
          routerConfig: appRouter,
        );
      },
    );
  }
}