import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'l10n/app_localizations.dart';
import 'env.dart';
import 'theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/core.dart';

final ValueNotifier<Locale> appLocale = ValueNotifier(const Locale('fr'));

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Charger les préférences de langue
  final prefs = await SharedPreferences.getInstance();
  final savedLanguage = prefs.getString('app_language') ?? 'fr';
  appLocale.value = Locale(savedLanguage);

  // Initialiser Supabase
  await Supabase.initialize(url: Env.supabaseUrl, anonKey: Env.supabaseAnonKey);

  // Initialiser les services
  setupServiceLocator();

  // Initialiser le router
  AppRouter().initialize();

  runApp(const NorvegeIAApp());
}

class NorvegeIAApp extends StatefulWidget {
  const NorvegeIAApp({super.key});

  @override
  State<NorvegeIAApp> createState() => _NorvegeIAAppState();
}

class _NorvegeIAAppState extends State<NorvegeIAApp> {
  late AppErrorHandler _errorHandler;

  @override
  void initState() {
    super.initState();
    _errorHandler = AppErrorHandler();
    // Enregistrer les callbacks de gestion d'erreurs
    _errorHandler.registerErrorCallbacks(
      onError: (message, {required AppErrorType type}) {
        if (mounted) {
          AppErrorHandler.showErrorSnackbar(
            context,
            message,
            backgroundColor: _getErrorColor(type),
          );
        }
      },
      onClear: () {
        // Optionnel: implémenter le nettoyage
      },
    );
  }

  Color _getErrorColor(AppErrorType type) {
    return switch (type) {
      AppErrorType.authentication => const Color(0xFFF39C12), // Orange
      AppErrorType.network => const Color(0xFF3498DB), // Bleu
      AppErrorType.aiService => const Color(0xFF9B59B6), // Violet
      AppErrorType.validation => const Color(0xFFE67E22), // Orange foncé
      _ => const Color(0xFFE74C3C), // Rouge
    };
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: appLocale,
      builder: (context, locale, child) {
        return MultiProvider(
          providers: getAppProviders(),
          child: MaterialApp.router(
            locale: locale,
            onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
            debugShowCheckedModeBanner: false,
            theme: appTheme,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            routerConfig: AppRouter().router,
          ),
        );
      },
    );
  }
}
