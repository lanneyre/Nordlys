# Architecture Refactorisée - Guide

## 📁 Structure du Projet

```
lib/
├── core/                  # Logique métier centralisée
│   ├── constants.dart     # Constantes app
│   ├── service_locator.dart  # Injection de dépendances
│   ├── validation_helper.dart # Validation
│   ├── error_handler.dart    # Gestion d'erreurs
│   └── core.dart          # Barrel export
├── models/                # Data models
├── screens/
│   ├── view_models/       # **NOUVEAU** - Logique métier
│   └── *.dart            # UI Screens
├── services/              # Logique métier (Auth, AI, TTS)
├── widgets/
│   ├── profile/           # **NOUVEAU** - Widgets profil réutilisables
│   ├── chat/
│   ├── login/
│   └── ...
├── utils/                 # Helpers (logger, text fields, etc)
├── l10n/                  # Localisation
├── main.dart              # Entry point
└── theme.dart             # Thème global
```

## 🎯 Améliorations Clés

### 1. **Service Locator (Injection de Dépendances)**

```dart
// Avant:
final _authService = AuthService();

// Après:
final authService = ServiceLocator.authService;
```

**Avantages:**

- Easier testing (mock services)
- Centralised instance management
- Réduction des créations répétées

### 2. **ViewModels (Séparation Logique/UI)**

- `ProfileViewModel` centralise toute la logique du profil
- ChangeNotifier pour la réactivité
- Plus facile à tester et maintenir

```dart
// Dans le widget:
final viewModel = Provider.of<ProfileViewModel>(context);
viewModel.updateUsername(value);
await viewModel.saveProfile();
```

### 3. **Constants Centralisées**

```dart
// Avant: Valeurs éparpillées partout
const Duration(seconds: 30)
'avatars'
8

// Après:
AppConstants.apiTimeout
AppConstants.supabaseBucketAvatars
AppDimensions.paddingSmall
```

### 4. **Validation Centralisée**

```dart
// Avant: Logique dupliquée dans 4 screens
if (email.isEmpty) { /* code */ }

// Après:
final error = ValidationHelper.validateEmail(email);
```

### 5. **Error Handling Unifié**

```dart
try {
  await authService.signIn(email, password);
} on Exception catch (e) {
  final appError = ErrorHandler.handleError(e, l10n);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(appError.message)),
  );
}
```

### 6. **Widgets Réutilisables**

```dart
// Avant: ProfileScreen.dart (454 lignes!)
// Après: Extraction en composants
ProfileSection(
  title: 'Votre Objectif',
  child: NordlysTextField(...),
)
```

## 🔧 Prochaines Étapes pour Votre Équipe

### Étape 1: Mise à jour de main.dart

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await Supabase.initialize(url: Env.supabaseUrl, anonKey: Env.supabaseAnonKey);
  
  // Setup services
  setupServiceLocator();
  
  // Load saved language
  final prefs = await SharedPreferences.getInstance();
  final savedLanguage = prefs.getString('app_language') ?? 'fr';
  appLocale.value = Locale(savedLanguage);
  
  runApp(const NorvegeIAApp());
}
```

### Étape 2: Refactoriser ProfileScreen avec ViewModel

```dart
class ProfileScreen extends StatefulWidget {
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late ProfileViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ProfileViewModel();
    _viewModel.loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        return Scaffold(
          // Utiliser _viewModel.username, etc.
        );
      },
    );
  }
}
```

### Étape 3: Utiliser les Widgets Réutilisables

```dart
ProfileSection(
  title: 'Qui êtes-vous ?',
  child: NordlysTextField(
    controller: _nameController,
    label: 'Nom',
  ),
)
```

## 📊 Bénéfices de cette Architecture

| Aspect              | Avant                   | Après                       |
| ------------------- | ----------------------- | --------------------------- |
| **Testabilité**     | Difficile (hard-coded)  | Facile (services mockables) |
| **Maintenabilité**  | Logique éparpillée      | Centralisée                 |
| **Réutilisabilité** | Duplication             | Composants partagés         |
| **Scalabilité**     | Screens qui grossissent | ViewModels modulaires       |
| **Debugging**       | Chercher partout        | Breakpoints ciblés          |

## 🚀 Best Practices Appliquées

✅ Single Responsibility Principle ✅ DRY (Don't Repeat Yourself) ✅ Dependency
Injection ✅ Clear separation of concerns ✅ Consistent error handling ✅
Centralized configuration

## 📚 Ressources

- [Flutter Best Practices](https://flutter.dev/docs/testing/best-practices)
- [GetIt Documentation](https://pub.dev/packages/get_it)
- [MVVM Pattern](https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93viewmodel)

---

**Prochaines refactorisations à considérer:**

- [ ] Intégrer Riverpod ou Provider state management
- [ ] Créer des Feature modules
- [ ] Ajouter Builder patterns pour objets complexes
- [ ] Tests unitaires pour ViewModels
- [ ] Intégrer des repositories pour l'accès aux données
