import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'l10n/app_localizations.dart';
import 'env.dart';
import 'theme.dart';
import 'screens/auth_gate.dart';
import 'package:shared_preferences/shared_preferences.dart'; // <-- 1. LE NOUVEL IMPORT
import 'core/service_locator.dart'; // (Ajustez le chemin du dossier si nécessaire)

final ValueNotifier<Locale> appLocale = ValueNotifier(const Locale('fr'));

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 4. On ouvre le "petit carnet de mémoire" du téléphone
  final prefs = await SharedPreferences.getInstance();

  // 5. On cherche la langue sauvegardée (si elle n'existe pas, on met 'fr' par défaut)
  final savedLanguage = prefs.getString('app_language') ?? 'fr';

  // 6. On met à jour notre variable avec la langue trouvée
  appLocale.value = Locale(savedLanguage);

  // 7. On initialise Supabase AVANT de lancer l'app
  await Supabase.initialize(url: Env.supabaseUrl, anonKey: Env.supabaseAnonKey);

  setupServiceLocator();

  runApp(const NorvegeIAApp());
}

class NorvegeIAApp extends StatelessWidget {
  const NorvegeIAApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: appLocale,
      builder: (context, locale, child) {
        return MaterialApp(
          // --- ET ON PASSE LA LANGUE ICI ! ---
          locale: locale,
          onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
          debugShowCheckedModeBanner: false,
          theme: appTheme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const AuthGate(),
        );
      },
    );
  }
}
