import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'constants/app_colors.dart';
import 'constants/stellantis_colors.dart';
import 'config/feature_flags.dart';
import 'screens/login_page.dart';
import 'screens/dealer_home_page.dart';
import 'providers/theme_provider.dart';
import 'providers/language_provider.dart';
import 'models/language_model.dart';

class StellantisApp extends StatelessWidget {
  const StellantisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: Consumer2<ThemeProvider, LanguageProvider>(
        builder: (context, themeProvider, languageProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.themeMode,
            theme: StellantisTheme.lightTheme,
            darkTheme: StellantisTheme.darkTheme,
            // Language configuration
            locale: languageProvider.currentLocale,
            supportedLocales: SupportedLanguages.allLocales,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            localeResolutionCallback: (locale, supportedLocales) {
              // Check if the device locale is supported
              if (locale != null) {
                for (var supportedLocale in supportedLocales) {
                  if (supportedLocale.languageCode == locale.languageCode &&
                      supportedLocale.countryCode == locale.countryCode) {
                    return supportedLocale;
                  }
                }
                // If country code doesn't match, try matching just language code
                for (var supportedLocale in supportedLocales) {
                  if (supportedLocale.languageCode == locale.languageCode) {
                    return supportedLocale;
                  }
                }
              }
              // Default to English (US)
              return const Locale('en', 'US');
            },
            // TEMP: Bypass auth for local/dev. Disable after deployment.
            home: FeatureFlags.bypassAuth ? const DealerHomePage() : const LoginPage(),
          );
        },
      ),
    );
  }
}

/*
 * ========================================================================
 * End of app.dart
 * Author: Rahul Raja
 * Website: https://www.stellantis.com/
 * ========================================================================
 */
